extends CanvasLayer

@onready var resume_button = $Panel/VBoxContainer/ButtonResume
@onready var main_menu_button = $Panel/VBoxContainer/ButtonMenu
@onready var quit_button = $Panel/VBoxContainer/ButtonQuit


func _ready():
	resume_button.pressed.connect(_on_resume_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	quit_button.pressed.connect(_on_quit_pressed)


func _on_resume_pressed():
	get_tree().paused = false
	visible = false


func _on_main_menu_pressed():
	get_tree().paused = false
	SceneStack.pop_scene()
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")


func _on_quit_pressed():
	get_tree().quit()
