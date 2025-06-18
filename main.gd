extends Node

func _ready():
	call_deferred("_start_game")

func _start_game():
	SceneStack.reset_stack(load("res://mainmenu.tscn"))
