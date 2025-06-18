class_name DeckView
extends VBoxContainer

@onready var filter_box = $FilterBar/FilterBox
@onready var side_filter = $FilterBar/SideFilter
@onready var faction_filter = $FilterBar/FactionFilter
@onready var type_filter = $FilterBar/TypeFilter
@onready var deck_list = $ScrollContainer/CardGrid
@onready var total_label = $TotalLabel

signal card_clicked(card_data: Dictionary)

var card_scene = preload("res://cards/Card.tscn")

var deck: Array = []
var all_factions: Array = []
var all_types: Array = []

const FACTION_TO_SIDE := {
	"Shaper": "Runner",
	"Criminal": "Runner",
	"Anarch": "Runner",
	"Neutral": "Runner",
	"HB": "Corp",
	"Jinteki": "Corp",
	"NBN": "Corp",
	"Weyland": "Corp"
}

const VALID_TYPES := {
	"Runner": ["Program", "Hardware", "Resource", "Event"],
	"Corp": ["Agenda", "Asset", "Operation", "Upgrade", "ICE"]
}


func _ready():
	filter_box.text_changed.connect(_refresh)
	side_filter.item_selected.connect(_refresh)
	faction_filter.item_selected.connect(_refresh)
	type_filter.item_selected.connect(_refresh)


func set_deck(new_deck: Array):
	deck = new_deck
	_collect_filter_options()
	_setup_filters()
	_refresh()


func _collect_filter_options():
	var faction_set := {}
	var type_set := {}
	for entry in deck:
		faction_set[entry.get("faction", "")] = true
		type_set[entry.get("type", "")] = true
	all_factions = faction_set.keys()
	all_types = type_set.keys()
	all_factions.sort()
	all_types.sort()


func _setup_filters():
	side_filter.clear()
	side_filter.add_item("All")
	side_filter.add_item("Runner")
	side_filter.add_item("Corp")

	faction_filter.clear()
	faction_filter.add_item("All")
	for f in all_factions:
		faction_filter.add_item(f)

	type_filter.clear()
	type_filter.add_item("All")
	for t in all_types:
		type_filter.add_item(t)


func _refresh(_val = null):
	# Clear current list
	for child in deck_list.get_children():
		deck_list.remove_child(child)
		child.queue_free()

	var query = filter_box.text.strip_edges().to_lower()
	var selected_side = side_filter.get_item_text(side_filter.get_selected_id())
	var selected_faction = faction_filter.get_item_text(faction_filter.get_selected_id())
	var selected_type = type_filter.get_item_text(type_filter.get_selected_id())

	var total = 0
	for entry in deck:
		var card = null
		if "data" in entry:
			card = entry["data"]
		else:
			card = entry

		var title = card.get("title", "").to_lower()
		var faction = card.get("faction", "")
		var side = card.get("side", "")
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

		var card_instance = card_scene.instantiate()
		card_instance.init_from_json(card)
		card_instance.clicked.connect(
			func(card_data):
				print("view click: ", card_instance.card_data["title"])
				emit_signal("card_clicked", card_instance.card_data)
		)
		deck_list.add_child(card_instance)

		#total += count

	total_label.text = "Total cards: %d" % total
