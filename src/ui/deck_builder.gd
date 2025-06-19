class_name DeckBuilder
extends Control

@onready var deck_title = $MarginContainer/VBoxContainer/TopBar/DeckTitle

@onready var back_button = $MarginContainer/VBoxContainer/HBoxContainer/CardSelector/BackButton
@onready var save_button = $MarginContainer/VBoxContainer/HBoxContainer/DeckView/SaveButton

@onready var preview = $MarginContainer/VBoxContainer/HBoxContainer/CardPreview/PreviewRect
@onready var add_button = $MarginContainer/VBoxContainer/HBoxContainer/CardPreview/HBoxContainer/ButtonAdd
@onready var remove_button = $MarginContainer/VBoxContainer/HBoxContainer/CardPreview/HBoxContainer/ButtonRemove

@onready var card_selector = $MarginContainer/VBoxContainer/HBoxContainer/CardSelector
@onready var deck_view = $MarginContainer/VBoxContainer/HBoxContainer/DeckView

var card_scene = preload("res://cards/Card.tscn")
var my_deck: Array = []
var selected_card = {}


func _ready():
	back_button.pressed.connect(func(): SceneStack.pop_scene())
	save_button.pressed.connect(_on_save_pressed)

	my_deck = load_deck_from_file("user://my_deck.json")
	_show_card_pool()
	card_selector.card_clicked.connect(_select_card)
	deck_view.card_clicked.connect(_select_card)
	add_button.pressed.connect(func():_add_card_to_deck(selected_card))
	remove_button.pressed.connect(func():_remove_card_from_deck(selected_card))


func _show_card_pool():
	card_selector.set_deck(CardDatabase.get_minimal_card_list())
	deck_view.set_deck(my_deck)
	

func _select_card(card_data: Dictionary):
	var card_set = card_data.get("set", null)
	var id = card_data.get("id", null)
	if card_set == null or id == null:
		push_warning("Card is missing deck ID/set: %s" % card_data.get("title", "???"))
		return
		
	var path = "res://cards/art/%s/%s.jpg" % [card_set, int(id)]
	var texture = load(path)
	preview.texture = texture
	
	selected_card = card_data


func _add_card_to_deck(card_data: Dictionary):
	print("Adding: ", card_data)
	var card_set = card_data.get("set", null)
	var id = card_data.get("id", null)
	if card_set == null or id == null:
		push_warning("Card is missing deck ID/set: %s" % card_data.get("title", "???"))
		return

	for entry in my_deck:
		if entry["set"] == card_set and entry["id"] == id:
			entry["count"] += 1
			_refresh_deck_list()
			return

	# If not found, add new entry
	my_deck.append({ "set": card_set, "id": id, "count": 1 })
	_refresh_deck_list()


func _remove_card_from_deck(card_data: Dictionary):
	print("Removing: ",card_data)
	var card_set = card_data.get("set", null)
	var id = card_data.get("id", null)

	for i in range(my_deck.size()):
		var entry = my_deck[i]
		if entry["set"] == card_set and entry["id"] == id:
			entry["count"] -= 1
			if entry["count"] <= 0:
				my_deck.remove_at(i)
			_refresh_deck_list()
			return

	push_warning("Tried to remove card not in deck: %s" % card_data.get("title", "???"))


func _refresh_deck_list():
	var validation_result = validate_deck(my_deck)
	deck_view.set_deck(my_deck, validation_result["invalid_cards"])
	print("Validation:" , validate_deck(my_deck))


func _on_save_pressed():
	var file = FileAccess.open("user://my_deck.json", FileAccess.WRITE)
	if file:
		var deck_json = { "title": deck_title.text, "cards": my_deck }
		file.store_string(JSON.stringify(deck_json, "\t"))
		print("✅ Deck saved to user://my_deck.json")
	else:
		push_error("❌ Failed to save deck")


func load_deck_from_file(path: String) -> Array:
	var loaded_deck: Array = []
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("Failed to open deck file: %s" % path)
		return loaded_deck

	var parsed: Dictionary = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Invalid deck format")
		return loaded_deck

	for entry in parsed.get("cards", []):
		if entry.has("set") and entry.has("id") and entry.has("count"):
			loaded_deck.append(entry)
	
	deck_title.text = parsed.get("title", "")
	return loaded_deck

func validate_deck(deck: Array) -> Dictionary:
	var result = {
		"valid": true,
		"errors": [],
		"identity": null,
		"total_cards": 0,
		"influence_used": 0,
		"invalid_cards": {}
	}

	# Count identity cards
	var identities = deck.filter(func(e): return CardDatabase.get_card_by_set_and_id(e["set"], e["id"]).get("type") == "Identity")

	if identities.size() != 1:
		result["valid"] = false
		result["errors"].append("Deck must include exactly one Identity card.")
		return result

	var identity = CardDatabase.get_card_by_set_and_id(identities[0]["set"], identities[0]["id"])
	result["identity"] = identity
	if identities.size() > 1:
		result["valid"] = false
		result["errors"].append("Must have exactly 1 Identity")
		
	var side = identity["deck"]["side"]
	var faction = identity["deck"]["faction"]
	var min_cards = int(identity.get("cardsmin", 0))
	var influence_limit = int(identity.get("influence", 0))

	var card_total = 0
	var influence_total = 0

	for entry in deck:
		var card = CardDatabase.get_card_by_set_and_id(entry["set"], entry["id"])
		var key = "%s|%s" % [entry["set"], entry["id"]]
		
		if card.is_empty():
			result["valid"] = false
			result["errors"].append("Unknown card: %s #%d" % [entry["set"], entry["id"]])
			result["invalid_cards"][key] = "Unknown card"
			continue

		# Skip identity in count
		if card.get("type") == "Identity":
			continue

		var count = entry["count"]
		card_total += count

		# Check side match
		if card["deck"]["side"] != side:
			result["valid"] = false

		# Enforce max copies
		var limit = int(card["deck"].get("limit", 3))
		if count > limit:
			result["valid"] = false
			result["errors"].append("Too many copies of '%s' (max %d)" % [card["title"], limit])
			result["invalid_cards"][key] = "Too many copies"
			
		if card["deck"]["side"] != identity["deck"]["side"]:
			result["valid"] = false
			result["errors"].append("Card '%s' is the wrong side" % card["title"])
			result["invalid_cards"][key] = "Wrong side"
			
		# Count influence
		if card["deck"]["faction"] != identity["deck"]["faction"]:
			var inf = int(card.get("influence", 0)) * count
			influence_total += inf
			print("→ %s (%d×) costs %d influence" % [card["title"], count, inf])


	result["total_cards"] = card_total
	result["influence_used"] = influence_total

	if card_total < min_cards:
		result["valid"] = false
		result["errors"].append("Deck must have at least %d cards (has %d)." % [min_cards, card_total])

	if influence_total > influence_limit:
		result["valid"] = false
		result["errors"].append("Influence used (%d) exceeds limit (%d)." % [influence_total, influence_limit])

	return result
