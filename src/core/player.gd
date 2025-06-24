extends Node
class_name Player

@export var player_ui: Control
@export var player_field: Node3D

var game_manager: Node = null
var my_turn: bool = false

var side: String = ""
var faction: String = ""
var identity_id: String = ""
var id_ui: TextureRect
var faction_ui: TextureRect
var credit_button: TextureButton
var credit_counter: Label
var click_counter: Label

var deck_zone: Node3D
var trash_zone: Node3D

var deck: Array = []
var hand: Array = []
var hand_limit: int = 5
var credits: int = 0
var clicks: int = 0
var click_max: int = 0
var income: int = 0


func _ready() -> void:
	print("prep: ", self.name)
	var id_panel = player_ui.get_node("HBoxContainer/IdentityPanel")
		
	id_ui = id_panel.get_node("HBoxContainer/IdentityCard") as TextureRect
	faction_ui = id_panel.get_node("HBoxContainer/Resources/FactionIcon") as TextureRect
	credit_counter = id_panel.get_node("HBoxContainer/Resources/Credits") as Label
	click_counter = id_panel.get_node("HBoxContainer/Resources/Clicks") as Label
	credit_button = id_panel.get_node("HBoxContainer/Resources/CreditIcon") as TextureButton
	credit_button.pressed.connect(click_for_credit)
	
	deck_zone = player_field.get_node("Deck")
	var deck_select = deck_zone.get_node("Area3D")
	deck_select.input_event.connect(_on_deck_event)

	trash_zone = player_field.get_node("Trash")
	var top_card = trash_zone.get_node("TopCard")
	top_card.material_override = top_card.material_override.duplicate()


func load_deck_from_file(path: String):
	deck.clear()
	var intermediate_deck = CardDatabase.load_deck_from_file(path)
	for card in intermediate_deck:
		var card_data = CardDatabase.get_card_by_set_and_id(card["set"], card["id"])
		if card_data["type"] == "Identity":
			side = card_data["deck"]["side"]
			faction = card_data["deck"]["faction"]
			identity_id = card_data["title"]
			var asset_path = "res://cards/art/%s/%s.jpg" % [card_data["deck"]["set"], int(card_data["deck"]["id"])]
			var texture = load(asset_path)
			id_ui.texture = texture
			asset_path = "res://Faction Glyphs/NSG_%s.svg" % [card_data["deck"]["faction"].to_upper()]
			texture = load(asset_path)
			faction_ui.texture = texture
		else:
			for i in range(card["count"]):
				deck.append({"set":card["set"], "id":card["id"]})


func shuffle_deck():
	deck.shuffle()


func use_clicks(amount: int = 1):
	clicks -= amount
	click_counter.text = "%d" % clicks
	if clicks <= 0:
		game_manager.turn_manager.end_turn(self)

func gain_clicks(amount: int = 1):
	print("Gaining clicks: ", amount)
	clicks += amount
	click_counter.text = "%d" % clicks

func add_credits(amount: int):
	credits += amount
	credit_counter.text = "%d" % credits
	
func remove_credits(amount: int):
	credits -= amount
	credit_counter.text = "%d" % credits

func click_for_credit():
	if my_turn and clicks >= 1:
		add_credits(1)
		use_clicks(1)
	else:
		push_warning("Cannot buy credit, not your turn or not enough credits")

func click_for_card():
	use_clicks(1)
	await animate_to_camera(draw_card)

func _on_deck_event(camera: Camera3D,
					event: InputEvent, 
					position: Vector3, 
					normal: Vector3, 
					shape_idx: int):
	if event is InputEventMouseButton and event.pressed:
		if my_turn:
			click_for_card()
		else:
			print("Not your turn, cannot draw card")
			pass
	
func draw_card():
	if deck.is_empty():
		push_warning("Deck is empty")
		return {}
	var card_data = deck.pop_front()
	hand.append(card_data)
	var card = player_ui.get_node("HBoxContainer/Hand").add_card(card_data)
	card.set_meta("set", card_data["set"])
	card.set_meta("id", card_data["id"])
	card.connect("clicked", func(clicked): _on_card_clicked(clicked))


func draw_starting_hand(count := 5):
	for i in range(count):
		await animate_to_camera(draw_card)


func animate_to_camera(on_finish: Callable):
	var target_world_pos = player_field.position + player_field.basis.z + Vector3.UP
	var card_node = deck_zone.get_node("TopCard")
	var tween = create_tween()
	tween.tween_property(card_node, "global_position", target_world_pos, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(on_finish)
	await tween.finished
	target_world_pos = deck_zone.get_node("Stack/TopMarker").global_position
	card_node.global_position = target_world_pos

func _on_card_clicked(card: TextureButton):
	if !my_turn || clicks <= 0: 
		push_warning("Trying to play card off turn")
		return
	use_clicks()
	
	var card_data = CardDatabase.get_card_by_set_and_id(card.get_meta("set"), card.get_meta("id"))
	var hand_ui = player_ui.get_node("HBoxContainer/Hand")
	await hand_ui.play_card(card)
		
	var cardtype = card_data["type"]
	match cardtype:
		"Resource", "Hardware", "Program":
			add_field_card(card)
		"Event":
			add_trash_card(card)
		
func add_field_card(card: TextureButton):
	var card_data = CardDatabase.get_card_by_set_and_id(card.get_meta("set"), card.get_meta("id"))
	var path = "res://cards/art/%s/%d.jpg" % [card.get_meta("set"), card.get_meta("id")]
	var texture = load(path)
	var cardtype = card_data["type"]
	var zone = null
	var card3d = preload("res://cards/card3d.tscn").instantiate()
	card3d.set_meta("set", card.get_meta("set"))
	card3d.set_meta("id", card.get_meta("id"))
	
	card3d.material_override = card3d.material_override.duplicate()
	card3d.material_override.set_shader_parameter("front_tex", texture)
	
	match cardtype:
		"Resource":
			zone = player_field.get_node("InnerLayer")
		"Hardware":
			zone = player_field.get_node("MidLayer")
		"Program":
			zone = player_field.get_node("OuterLayer")
	
	if zone != null:
		zone.add_child(card3d)
		card3d.rotation_degrees = Vector3(0,0,0)
		var offset = (zone.get_child_count()-1) * -0.4
		card3d.position = Vector3(offset, 0, 0)

func add_trash_card(card: TextureButton):
	#var card_data = CardDatabase.get_card_by_set_and_id(card.get_meta("set"), card.get_meta("id"))
	var path = "res://cards/art/%s/%d.jpg" % [card.get_meta("set"), card.get_meta("id")]
	var texture = load(path)
	
	if !trash_zone.visible:
		trash_zone.visible = true
	var top_card = trash_zone.get_node("TopCard")
	top_card.material_override.set_shader_parameter("front_tex", texture)

func start_turn():
	add_credits(income)
