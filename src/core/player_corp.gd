extends Node

var servers = []

func play_card(card_data: Dictionary):
	var cardtype = card_data["type"]
	match cardtype:
		"ICE":
			play_ice()
		"Agenda":
			play_agenda()
		"Asset":
			play_asset()
		"Upgrade":
			play_upgrade()
		"Operation":
			play_operation()

func play_ice():
	get_parent().use_clicks()

func play_agenda():
	get_parent().use_clicks()

func play_asset():
	get_parent().use_clicks()

func play_upgrade():
	get_parent().use_clicks()

func play_operation():
	get_parent().use_clicks()

func trash_resource():
	get_parent().use_clicks()

func purge_virus_counters():
	get_parent().use_clicks(3)
