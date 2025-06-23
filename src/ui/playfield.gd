class_name playfield
extends CanvasLayer

@onready var player_container = $BottomLeft/HBoxContainer/IdentityPanel
@onready var opponent_container = $TopRight/HBoxContainer/IdentityPanel


func _ready():
	var style: StyleBoxFlat = player_container.get_theme_stylebox("panel")
	style.bg_color = Color(1, 0, 0, .1)
	style.border_color = Color(1, 0, 0, 1)
