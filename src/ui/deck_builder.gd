class_name DeckBuilder
extends Control

@onready var deck_title = $MarginContainer/VBoxContainer/TopBar/DeckTitle

@onready var back_button = $MarginContainer/VBoxContainer/HBoxContainer/CardSelector/BackButton
@onready var save_button = $MarginContainer/VBoxContainer/HBoxContainer/DeckView/Buttons/SaveButton
@onready var load_button = $MarginContainer/VBoxContainer/HBoxContainer/DeckView/Buttons/LoadButton
@onready var deck_selector = $DeckSelector

@onready var preview = $MarginContainer/VBoxContainer/HBoxContainer/CardPreview/PreviewRect
@onready var add_button = $MarginContainer/VBoxContainer/HBoxContainer/CardPreview/HBoxContainer/ButtonAdd
@onready var remove_button = $MarginContainer/VBoxContainer/HBoxContainer/CardPreview/HBoxContainer/ButtonRemove

@onready var card_selector = $MarginContainer/VBoxContainer/HBoxContainer/CardSelector
@onready var deck_view = $MarginContainer/VBoxContainer/HBoxContainer/DeckView

var id_label: Label

var my_deck: Dictionary = {"title":"","identity":{},"cards":[]}
var selected_card: TextureButton


func _ready():
	back_button.pressed.connect(func(): SceneStack.pop_scene())
	save_button.pressed.connect(_on_save_pressed)
	load_button.pressed.connect(_on_load_pressed)

	id_label = Label.new()
	deck_view.get_node("HBoxContainer").add_child(id_label)

	card_selector.card_clicked.connect(_select_card)
	deck_view.card_clicked.connect(_select_card)
	add_button.pressed.connect(_add_card_to_deck)
	remove_button.pressed.connect(_remove_card_from_deck)

	deck_title.text_submitted.connect(func(text): my_deck["title"] = text)
	deck_selector.deck_loaded.connect(func(deck): 
		my_deck = deck
		_refresh_deck_list()
		)

	_show_card_pool()


func _show_card_pool():
	card_selector.set_deck(CardDatabase.get_minimal_card_list())
	deck_view.set_deck(my_deck["cards"])


func _select_card(card: TextureButton):
	print("Selected card: ", card)
	var card_set = card.get_meta("set")
	var id = int(card.get_meta("id"))
	if card_set == null or id == null:
		push_warning("Card is missing deck ID/set")
		return

	var path = "res://cards/art/%s/%s.jpg" % [card_set, id]
	var texture = load(path)
	preview.texture = texture

	selected_card = card


func _add_card_to_deck():
	var card_set = selected_card.get_meta("set")
	var id = int(selected_card.get_meta("id"))
	if card_set == null or id == null:
		push_warning("Card is missing deck ID/set")
		return

	var full_card_data = CardDatabase.get_card_by_set_and_id(card_set, id)
	if full_card_data["type"] == "Identity":
		my_deck["identity"] = {"set": card_set, "id": id}
		id_label.text = full_card_data["title"]
		_refresh_deck_list()
		return

	if my_deck["identity"].is_empty():
		print("No identity set, cannot add non-identity cards")
		return

	for entry in my_deck["cards"]:
		if entry["set"] == card_set and entry["id"] == id:
			entry["count"] += 1
			_refresh_deck_list()
			return

	# If not found, add new entry
	my_deck["cards"].append({"set": card_set, "id": id, "count": 1})
	_refresh_deck_list()


func _remove_card_from_deck():
	var card_set = selected_card.get_meta("set")
	var id = selected_card.get_meta("id")

	for i in range(my_deck["cards"].size()):
		var entry = my_deck["cards"][i]
		if entry["set"] == card_set and entry["id"] == id:
			entry["count"] -= 1
			if entry["count"] <= 0:
				my_deck["cards"].remove_at(i)
			_refresh_deck_list()
			return

	push_warning("Tried to remove card not in deck")


func _refresh_deck_list():
	var validation_result = validate_deck(my_deck)
	print(my_deck)
	id_label.text = CardDatabase.get_card_by_set_and_id(my_deck["identity"]["set"], int(my_deck["identity"]["id"])).get("title", "No Identity")
	deck_view.set_deck(my_deck["cards"], validation_result["invalid_cards"])
	print("Validation:", validate_deck(my_deck))


func _on_load_pressed():
	deck_selector.visible = true


func _on_save_pressed():
	if !DirAccess.dir_exists_absolute("user://decks"):
		DirAccess.make_dir_absolute("user://decks")
	if my_deck["title"] == "":
		push_error("❌ Deck title cannot be empty")
		return
	var file = FileAccess.open("user://decks/%s.json" % my_deck["title"] , FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(my_deck, "\t"))
		print("✅ Deck saved to user://my_deck.json")
	else:
		push_error("❌ Failed to save deck")


func validate_deck(deck: Dictionary) -> Dictionary:
	var result = {
		"valid": true,
		"errors": [],
		"identity": null,
		"total_cards": 0,
		"influence_used": 0,
		"invalid_cards": {}
	}

	# Count identity cards
	if my_deck["identity"].is_empty:
		result["valid"] = false
		result["errors"].append("Deck must include exactly one Identity card.")
		return result

	var identity = CardDatabase.get_card_by_set_and_id(my_deck["identity"]["set"], my_deck["identity"]["id"])
	result["identity"] = identity

	var side = identity["deck"]["side"]
	var faction = identity["deck"]["faction"]
	var min_cards = int(identity.get("cardsmin", 0))
	var influence_limit = int(identity.get("influence", 0))

	var card_total = 0
	var influence_total = 0

	for entry in deck["cards"]:
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
		result["errors"].append(
			"Deck must have at least %d cards (has %d)." % [min_cards, card_total]
		)

	if influence_total > influence_limit:
		result["valid"] = false
		result["errors"].append(
			"Influence used (%d) exceeds limit (%d)." % [influence_total, influence_limit]
		)

	return result
