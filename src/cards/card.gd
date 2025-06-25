class_name Card
extends TextureButton

signal clicked(card: TextureButton)

var tween: Tween


func _ready():
	material = material.duplicate()
	mouse_entered.connect(func(): modulate = Color(1.2, 1.2, 1.2))  # brighten on hover
	mouse_exited.connect(func(): modulate = Color(1, 1, 1))  # reset
	pressed.connect(
		func():
			modulate = Color(0.8, 0.8, 0.8)  # dim when pressed
			emit_signal("clicked")
	)
	_update_ui()


func _update_ui():
	var full_data = CardDatabase.get_card_by_set_and_id(get_meta("set"), get_meta("id"))
	var path = "res://cards/art/%s/%s.jpg" % [get_meta("set"), get_meta("id")]
	var texture = load(path)

	if texture is Texture2D:
		material.set_shader_parameter("card_tex", texture)
		match full_data["deck"]["faction"]:
			"Anarch":
				material.set_shader_parameter("rim_color", Color(1.0, 0.0, 0.0, 1.0))
			"Criminal":
				material.set_shader_parameter("rim_color", Color(0.0, 0.0, 1.0, 1.0))
			"Shaper":
				material.set_shader_parameter("rim_color", Color(0.0, 1.0, 0.0, 1.0))
			"NBN":
				material.set_shader_parameter("rim_color", Color(1.0, 1.0, 0.0, 1.0))
	else:
		push_warning("Missing card art: %s" % path)
