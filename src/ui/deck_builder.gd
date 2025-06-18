class_name DeckBuilder
extends Control

@onready var back_button = $MarginContainer/VBoxContainer/HSplitContainer/CardSelector/BackButton
@onready var save_button = $MarginContainer/VBoxContainer/HSplitContainer/DeckView/SaveButton

@onready var card_selector = $MarginContainer/VBoxContainer/HSplitContainer/CardSelector
@onready var deck_view = $MarginContainer/VBoxContainer/HSplitContainer/DeckView

var card_scene = preload("res://cards/Card.tscn")
var all_card_data: Array = []
var deck: Dictionary = {}  # key: card ID, value: count

var card_loader = preload("res://src/utils/card_loader.gd").new()

func _ready():
	back_button.pressed.connect(func(): SceneStack.pop_scene())

	all_card_data = card_loader.load_all_cards_from_folder("res://cards/data/System Gateway")
	_show_card_pool()
	save_button.pressed.connect(_on_save_pressed)


func _show_card_pool():
	card_selector.set_deck(all_card_data)
	var mydeck = load_deck_from_file("res://sample_deck.json")
	deck_view.set_deck(mydeck)
	

func _add_card_to_deck(card_data: Dictionary):
	var title = card_data.get("title", "")
	if not deck.has(title):
		deck[title] = {"data": card_data, "count": 0}
	deck[title]["count"] += 1
	_refresh_deck_list()


func _refresh_deck_list():
	return


func _on_save_pressed():
	var deck_json = {
		"cards": deck.values().map(func(entry): return {
			"id": entry["data"].get("deck", {}).get("id"),
			"set": entry["data"].get("deck", {}).get("set"),
			"title": entry["data"].get("title"),
			"count": entry["count"]
		})
	}
	var file = FileAccess.open("user://my_deck.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(deck_json, "\t"))


func load_deck_from_file(path: String) -> Array:
	var deck := []
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("Failed to open deck file: %s" % path)
		return deck

	var parsed: Dictionary = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Invalid deck format")
		return deck

	for card_entry in parsed.get("cards", []):
		var set: String = card_entry.get("set", "")
		var id: int = int(card_entry.get("id", -1))
		var count: int = card_entry.get("count", 1)
		var card := get_card_by_set_and_id(set, id)
		if card:
			deck.append({
				"data": card,
				"count": count
			})
		else:
			push_warning("Card not found: %s %d" % [set, id])
	return deck


func get_card_by_set_and_id(set: String, id: int) -> Dictionary:
	for card in all_card_data:
		if card.get("deck", {}).get("set") == set and card.get("deck", {}).get("id") == id:
			return card
	return {}
