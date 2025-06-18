extends Node

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
