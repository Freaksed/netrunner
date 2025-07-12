extends Control

@export var start_scene: PackedScene
@export var deck_builder_scene: PackedScene

@onready var view_cards_button = $RootContainer/VBoxContainer/ViewCardsButton
@onready var start_game_button = $RootContainer/VBoxContainer/StartGameButton
@onready var quit_button = $RootContainer/VBoxContainer/QuitButton


func _ready():
	view_cards_button.pressed.connect(_on_view_cards_pressed)
	start_game_button.pressed.connect(_on_start_game_pressed)
	quit_button.pressed.connect(_on_quit_pressed)


func _on_view_cards_pressed():
	SceneStack.push_scene(deck_builder_scene)


func _on_start_game_pressed():
	SceneStack.push_scene(start_scene)


func _on_quit_pressed():
	get_tree().quit()
