extends Node

const CARD_SIZE = Vector2(366, 512)
var card2d = preload("res://cards/card2d.tscn")
var card3d = preload("res://cards/card3d.tscn")

var all_card_data: Array = []


func _ready():
	# Load all cards once at startup
	all_card_data = CardDatabase.load_all_cards_from_folder("res://cards/data/System Gateway")
	all_card_data.sort_custom(
		func(a, b): return int(a.get("deck").get("id", -1)) < int(b.get("deck").get("id", -1))
	)
	print("Loaded %d cards into global database" % all_card_data.size())


func get_card_by_set_and_id(card_set: String, id: int) -> Dictionary:
	for card in all_card_data:
		if card.get("deck", {}).get("set") == card_set and card.get("deck", {}).get("id") == id:
			return card
	return {}


func get_minimal_card_list() -> Array:
	return all_card_data.map(
		func(card):
			return {"id": card.get("deck", {}).get("id"), "set": card.get("deck", {}).get("set")}
	)

func load_deck_from_file(path: String) -> Dictionary:
	var loaded_deck: Dictionary = {"title": "", "identity": {}, "cards":[]}
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("Failed to open deck file: %s" % path)
		return loaded_deck

	var parsed: Dictionary = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Invalid deck format")
		return loaded_deck
	
	loaded_deck["title"] = parsed.get("title", "")
	loaded_deck["identity"] = parsed.get("identity", {})
	for entry in parsed.get("cards", []):
		if entry.has("set") and entry.has("id") and entry.has("count"):
			loaded_deck["cards"].append(entry)

	return loaded_deck

func load_all_cards_from_folder(folder_path: String) -> Array:
	var cards: Array = []
	var dir = DirAccess.open(folder_path)
	if dir == null:
		push_error("Failed to open folder: %s" % folder_path)
		return []

	dir.list_dir_begin()
	while true:
		var file_name = dir.get_next()
		if file_name == "":
			break
		if file_name.ends_with(".json"):
			var full_path = folder_path.path_join(file_name)
			var card = load_card_from_file(full_path)
			if card:
				cards.append(card)
	dir.list_dir_end()

	return cards

func load_card_from_file(path: String) -> Dictionary:
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Failed to open card file: %s" % path)
		return {}
	var content = file.get_as_text()
	var result = JSON.parse_string(content)
	if result == null:
		push_error("Invalid JSON in file: %s" % path)
		return {}
	return result
