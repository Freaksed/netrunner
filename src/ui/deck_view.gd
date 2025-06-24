class_name DeckView
extends VBoxContainer

@onready var filter_box = $FilterBar/FilterBox
@onready var side_filter = $FilterBar/SideFilter
@onready var faction_filter = $FilterBar/FactionFilter
@onready var type_filter = $FilterBar/TypeFilter
@onready var deck_list = $ScrollContainer/CardGrid
@onready var total_label = $HBoxContainer/TotalLabel

signal card_clicked(card_data: Dictionary)

var deck: Array = []
var invalid_cards = {}
var all_factions: Array = []
var all_types: Array = []

var selected_side = "All"
var selected_faction = "All"
var selected_type = "All"

const FACTION_TO_SIDE := {
	"Shaper": "Runner",
	"Criminal": "Runner",
	"Anarch": "Runner",
	"Neutral": "Runner",
	"Haas-Bioroid": "Corp",
	"Jinteki": "Corp",
	"NBN": "Corp",
	"Weyland Consortium": "Corp"
}

const VALID_FACTIONS := {
	"Runner": ["Anarch", "Criminal", "Shaper"],
	"Corp": ["Haas-Bioroid", "Jinteki", "NBN", "Weyland Consortium"]
}

const VALID_TYPES := {
	"Runner": ["Program", "Hardware", "Resource", "Event"],
	"Corp": ["Agenda", "Asset", "Operation", "Upgrade", "ICE"]
}


func _ready():
	filter_box.text_changed.connect(_refresh)
	side_filter.item_selected.connect(
		func(index):
			selected_side = side_filter.get_item_text(index)
			_refresh()
	)
	faction_filter.item_selected.connect(
		func(index):
			selected_faction = faction_filter.get_item_text(index)
			_refresh()
	)
	type_filter.item_selected.connect(
		func(index):
			selected_type = type_filter.get_item_text(index)
			_refresh()
	)


func set_deck(new_deck: Array, invalid_map := {}):
	deck = new_deck
	invalid_cards = invalid_map
	_setup_filters()
	_refresh()


func _setup_filters():
	side_filter.clear()
	side_filter.add_item("All")
	side_filter.add_item("Corp")
	side_filter.add_item("Runner")

	faction_filter.clear()
	faction_filter.add_item("All")
	for side in VALID_FACTIONS:
		for faction in VALID_FACTIONS[side]:
			faction_filter.add_item(faction)

	type_filter.clear()
	type_filter.add_item("All")
	for side in VALID_TYPES:
		for type in VALID_TYPES[side]:
			type_filter.add_item(type)


func _refresh(_val = null):
	# Clear old children
	for child in deck_list.get_children():
		child.queue_free()

	var query = filter_box.text.strip_edges().to_lower()

	var total = 0

	for entry in deck:
		var card = CardDatabase.get_card_by_set_and_id(entry["set"], entry["id"])
		if card.is_empty():
			continue

		var title = card.get("title", "").to_lower()
		var faction = card.get("deck", {}).get("faction", "")
		var side = card.get("deck", {}).get("side", "")
		var card_type = card.get("type", "")

		if query != "" and not title.contains(query):
			continue
		if selected_side != "All" and side != selected_side:
			continue
		if selected_faction != "All" and faction != selected_faction:
			continue
		if selected_type != "All":
			var inferred_side = selected_side
			if inferred_side == "All" and selected_faction != "All":
				inferred_side = FACTION_TO_SIDE.get(selected_faction, null)
			var valid = VALID_TYPES.get(inferred_side, [])
			if selected_type not in valid or card_type != selected_type:
				continue

		var key = "%s|%s" % [entry["set"], entry["id"]]
		var is_invalid = invalid_cards.has(key)
		var tooltip = invalid_cards.get(key, "")

		var count = int(entry.get("count", 1))
		# Add N copies
		for i in range(count):
			var card_instance = CardDatabase.card2d.instantiate()
			card_instance.set_meta("set", entry["set"])
			card_instance.set_meta("id", int(entry["id"]))
			card_instance.custom_minimum_size = Vector2(93, 128)
			card_instance.clicked.connect(
				func(): emit_signal("card_clicked", card_instance)
			)

			if is_invalid:
				card_instance.modulate = Color(1.0, 0.8, 0.8)
				card_instance.tooltip_text = tooltip

			deck_list.add_child(card_instance)
			total += 1

	total_label.text = "Total cards: %d" % total
