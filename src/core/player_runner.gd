extends Node

var resources = []
var hardware = []
var programs = []

func play_card(card_data: Dictionary):
	var cardtype = card_data["type"]
	match cardtype:
		"Resource":
			play_resource()
		"Hardware":
			play_hardware()
		"Program":
			play_program()
		"Event":
			play_event()

func play_resource():
	get_parent().use_clicks()

func play_hardware():
	get_parent().use_clicks()

func play_program():
	get_parent().use_clicks()

func play_event():
	get_parent().use_clicks()

func run_server():
	get_parent().use_clicks()

func remove_tag():
	get_parent().use_clicks()
