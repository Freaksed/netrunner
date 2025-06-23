extends Node

@onready var esc_menu = $EscMenu


func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		esc_menu.visible = !esc_menu.visible
		get_tree().paused = esc_menu.visible


func _ready():
	call_deferred("_start_game")


func _start_game():
	SceneStack.reset_stack(load("res://scenes/mainmenu.tscn"))
