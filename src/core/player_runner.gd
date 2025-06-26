extends Node

var player: Node

var resources = []
var hardware = []
var programs = []

func play_card(card_data: Dictionary):
	var cardtype = card_data["type"]
	match cardtype:
		"Resource":
			play_resource(card_data)
		"Hardware":
			play_hardware(card_data)
		"Program":
			play_program(card_data)
		"Event":
			play_event(card_data)

func play_resource(card_data:Dictionary):
	player.use_clicks()
	player.play_card(card_data, "InnerLayer")

func play_hardware(card_data:Dictionary):
	player.use_clicks()
	player.play_card(card_data, "MidLayer")

func play_program(card_data:Dictionary):
	player.use_clicks()
	player.play_card(card_data, "OuterLayer")

func play_event(card_data:Dictionary):
	player.use_clicks()
	player.play_card(card_data, "Trash")

func run_server():
	player.use_clicks()

func remove_tag():
	player.use_clicks()
