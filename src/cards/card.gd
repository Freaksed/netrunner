class_name Card
extends TextureButton

signal clicked(card_data: Dictionary)

var card_data: Dictionary
var tween: Tween


func init_from_json(data: Dictionary):
	card_data = data
	if is_inside_tree():  # we're already ready
		_update_ui()


func _ready():
	mouse_entered.connect(func(): modulate = Color(1.2, 1.2, 1.2))  # brighten on hover
	mouse_exited.connect(func(): modulate = Color(1, 1, 1))  # reset
	pressed.connect(
		func():
			modulate = Color(0.8, 0.8, 0.8)  # dim when pressed
			emit_signal("clicked", {"id": card_data.get("id"), "set": card_data.get("set")})
	)

	if card_data:  # init_from_json was already called
		_update_ui()


func _update_ui():
	var card_set = card_data.get("set", "")
	var id = card_data.get("id", null)

	if card_set == "" or id == null:
		push_warning("Card missing deck set/id: ", card_data)
		return

	var path = "res://cards/art/%s/%s.jpg" % [card_set, int(id)]
	var texture = load(path)

	if texture is Texture2D:
		texture_normal = texture
	else:
		push_warning("Missing card art: %s" % path)
