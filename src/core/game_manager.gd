extends Node
class_name GameManager

@onready var local_player := $LocalPlayer
@onready var remote_player := $RemotePlayer
@onready var turn_manager := preload("res://src/core/turn_manager.gd").new()

func _ready() -> void:
	local_player.game_manager = self
	remote_player.game_manager = self
	set_up_game()
	turn_manager.start_turn(local_player)


func set_up_game():
	local_player.load_deck_from_file("user://my_deck.json")
	#remote_player.load_deck_from_file("user://my_deck.json")
	local_player.add_credits(5)
	remote_player.add_credits(5)
	local_player.shuffle_deck()
	remote_player.shuffle_deck()
	local_player.draw_starting_hand(5)
	remote_player.draw_starting_hand(5)
	match local_player.side:
		"Runner":
			print("Setting up Runner")
			local_player.click_max = 4
			local_player.income = 0
		"Corp":
			print("Setting up Corp")
			local_player.click_max = 3
			local_player.income = 0
		_:
			print("Unknown player side: ", local_player.side)
	match remote_player.side:
		"Runner":
			print("Setting up Runner")
			remote_player.click_max = 4
			remote_player.income = 0
		"Corp":
			print("Setting up Corp")
			remote_player.click_max = 3
			remote_player.income = 0
		_:
			print("Unknown player side: ", remote_player.side)


func start_round():
	print("New Game Round")


func end_turn(player: Node):
	if player == local_player:
		print("Local Player's turn ended")
	else:
		print("Remote Player's turn ended")
	
	# Reset player state for the next turn
	player.reset_turn_state()
	
	# Notify the turn manager to proceed to the next phase
	turn_manager.end_turn(player)
