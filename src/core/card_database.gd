extends Node

var all_card_data: Array = []

var card_loader = preload("res://src/utils/card_loader.gd").new()

func _ready():
	# Load all cards once at startup
	all_card_data = card_loader.load_all_cards_from_folder("res://cards/data/System Gateway")
	all_card_data.sort_custom(func(a,b):
		return int(a.get("deck").get("id", -1)) < int(b.get("deck").get("id", -1))
	)
	print("Loaded %d cards into global database" % all_card_data.size())

func get_card_by_set_and_id(card_set: String, id: int) -> Dictionary:
	for card in all_card_data:
		if card.get("deck", {}).get("set") == card_set and card.get("deck", {}).get("id") == id:
			return card
	return {}

func get_minimal_card_list() -> Array:
	return all_card_data.map(func(card):
		return {
			"id": card.get("deck", {}).get("id"),
			"set": card.get("deck", {}).get("set")
		}
	)
