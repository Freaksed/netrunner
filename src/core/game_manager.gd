extends Node
class_name GameManager

@onready var local_player := $LocalPlayer
@onready var remote_player := $RemotePlayer

func _ready() -> void:
	local_player.initialize_player() #.load_deck_from_file("user://my_deck.json")
	start_game()

func start_game():
	local_player.draw_starting_hand(5)
	#remote_player.draw_starting_hand(5)
	start_round()

func start_round():
	print("New Game Round")
