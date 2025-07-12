class_name EventBus
extends Node

# Card events
signal card_drawn(card: Card, player: Player)
signal card_installed(card: Card, player: Player)
signal card_played(card: Card, player: Player)
signal card_rezzed(card: Card, player: Player)
signal card_trashed(card: Card, player: Player)

# Game events
signal turn_begins(player: Player)
signal turn_ends(player: Player)
signal run_begins(server: String)
signal run_ends(server: String, successful: bool)
signal run_successful(server: String)
signal damage_taken(player: Player, damage_type: String, amount: int)
signal credits_gained(player: Player, amount: int)
signal tag_added(player: Player, amount: int)

# Usage example for emitting events
func emit_turn_begins(player: Player):
	turn_begins.emit(player)

func emit_turn_ends(player: Player):
	turn_ends.emit(player)

func emit_card_drawn(card: Dictionary, player: Player):
	card_drawn.emit(card, player)

func emit_card_played(card: Card, player: Player):
	card_played.emit(card, player)

func emit_card_installed(card: Card, player: Player):
	card_installed.emit(card, player)

func emit_card_rezzed(card: Card, player: Player):
	card_rezzed.emit(card, player)

func emit_card_trashed(card: Card, player: Player):
	card_trashed.emit(card, player)

func emit_run_begins(server: String):
	run_begins.emit(server)

func emit_run_ends(server: String, successful: bool):
	run_ends.emit(server, successful)

func emit_run_successful(server: String):
	run_successful.emit(server)

func emit_damage_taken(player: Player, damage_type: String, amount: int):
	damage_taken.emit(player, damage_type, amount)

func emit_tag_added(player: Player, amount: int):
	tag_added.emit(player, amount)

func emit_credits_gained(player: Player, amount: int):
	credits_gained.emit(player, amount)
