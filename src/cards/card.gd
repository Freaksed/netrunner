class_name Card
extends TextureButton

signal clicked(card: TextureButton)

var tween: Tween


func _ready():
	mouse_entered.connect(func(): modulate = Color(1.2, 1.2, 1.2))  # brighten on hover
	mouse_exited.connect(func(): modulate = Color(1, 1, 1))  # reset
	pressed.connect(
		func():
			modulate = Color(0.8, 0.8, 0.8)  # dim when pressed
			emit_signal("clicked")
	)
	_update_ui()


func _update_ui():
	var path = "res://cards/art/%s/%s.jpg" % [get_meta("set"), get_meta("id")]
	var texture = load(path)

	if texture is Texture2D:
		texture_normal = texture
	else:
		push_warning("Missing card art: %s" % path)
