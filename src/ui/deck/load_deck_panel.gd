extends CanvasLayer

signal deck_loaded(deck: Dictionary)

@onready var deck_list = $Panel/VBoxContainer/DeckList
@onready var load_button = $Panel/VBoxContainer/Buttons/Load
@onready var back_button = $Panel/VBoxContainer/Buttons/Cancel

const deck_path: String = "user://decks"
var deck_files: Array = []

func _ready():
	load_button.disabled = true

	back_button.pressed.connect(func(): visible = false)
	load_button.pressed.connect(_on_load_pressed)
	deck_list.item_selected.connect(_on_deck_selected)

	populate_deck_list()

func populate_deck_list():
	deck_files.clear()
	deck_list.clear()

	var dir = DirAccess.open(deck_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".json"):
				deck_files.append(file_name)
				deck_list.add_item(file_name)
			file_name = dir.get_next()
		dir.list_dir_end()

func _on_deck_selected(index: int):
	load_button.disabled = false

func _on_load_pressed():
	var selected_index = deck_list.get_selected_items()[0]
	var file_name = deck_files[selected_index]
	var file_path = deck_path + "/" + file_name
	var deck_data = CardDatabase.load_deck_from_file(file_path)
	emit_signal("deck_loaded", deck_data)
	visible = false
