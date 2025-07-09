class_name EventBus
extends Node

# Card events
signal card_installed(card: Card, player: Player)
signal card_played(card: Card, player: Player)
signal card_rezzed(card: Card, player: Player)
signal card_trashed(card: Card, player: Player)

# Game events
signal turn_begins(player: Player)
signal turn_ends(player: Player)
signal run_begins(server: String, runner: Player)
signal run_ends(server: String, runner: Player, successful: bool)
signal run_successful(server: String, runner: Player)
signal damage_taken(player: Player, damage_type: String, amount: int)
signal credits_gained(player: Player, amount: int)
signal tag_added(player: Player, amount: int)

# Usage example for emitting events
func emit_card_installed(card: Card, player: Player):
	card_installed.emit(card, player)

func emit_run_successful(server: String, runner: Player):
	run_successful.emit(server, runner)
