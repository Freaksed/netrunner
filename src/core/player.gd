extends Node
class_name Player

@export var player_ui: Control
@export var player_field: Node3D

var game_manager: Node = null
var my_turn: bool = false

var side: String = ""
var faction: String = ""
var identity_id: String = ""
var faction_ui: TextureRect
var credit_button: TextureButton
var credit_counter: Label
var click_counter: Label

var id_card: Node3D
var deck_zone: Node3D
var trash_zone: Node3D

var identity = {}

var deck: Array = []
var hand: Array = []
var trash: Array = []

var state: Node = null

var hand_limit: int = 5
var credits: int = 0
var clicks: int = 0
var click_max: int = 0
var income: int = 0


func _ready() -> void:
	var id_panel = player_ui.get_node("HBoxContainer/IdentityPanel")

	faction_ui = id_panel.get_node("Resources/FactionIcon") as TextureRect
	credit_counter = id_panel.get_node("Resources/Credits") as Label
	click_counter = id_panel.get_node("Resources/Clicks") as Label
	credit_button = id_panel.get_node("Resources/CreditIcon") as TextureButton
	credit_button.pressed.connect(click_for_credit)

	id_card = player_field.get_node("Identity")

	deck_zone = player_field.get_node("Deck")
	var deck_select = deck_zone.get_node("Area3D")
	deck_select.input_event.connect(_on_deck_event)

	trash_zone = player_field.get_node("Trash")
	var top_card = trash_zone.get_node("TopCard")
	top_card.material_override = top_card.material_override.duplicate()


func load_deck_from_file(path: String):
	deck.clear()
	var intermediate_deck = CardDatabase.load_deck_from_file(path)
	identity = CardDatabase.get_card_by_set_and_id(intermediate_deck["identity"]["set"], int(intermediate_deck["identity"]["id"]))
	side = identity["deck"]["side"]
	faction = identity["deck"]["faction"]
	identity_id = identity["title"]

	var asset_path = "res://cards/art/%s/%s.jpg" % [identity["deck"]["set"], int(identity["deck"]["id"])]
	var texture = load(asset_path)
	id_card.material_override = id_card.material_override.duplicate()
	id_card.material_override.set_shader_parameter("front_tex", texture)
	asset_path = "res://Faction Glyphs/NSG_%s.svg" % [identity["deck"]["faction"].to_upper()]
	texture = load(asset_path)
	faction_ui.texture = texture

	for card in intermediate_deck["cards"]:
		for i in range(card["count"]):
			deck.append({"set":card["set"], "id":card["id"]})

	state = Node.new()
	add_child(state)
	match side:
		"Corp": state.set_script(load("res://src/core/player_corp.gd"))
		"Runner": state.set_script(load("res://src/core/player_runner.gd"))
	state.player = self


func start_turn():
	add_credits(income)
	if side == "Corp":
		draw_card()


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
		use_clicks(1)
		add_credits(1)
	else:
		push_warning("Cannot buy credit, not your turn or not enough clicks")


func shuffle_deck():
	deck.shuffle()


func _on_deck_event(camera: Camera3D,
					event: InputEvent, 
					position: Vector3, 
					normal: Vector3, 
					shape_idx: int):
	if event is InputEventMouseButton and event.pressed:
		if my_turn:
			use_clicks(1)
			var drawn_card = await draw_card()
			# Emit event for data-driven abilities
			if drawn_card:
				game_manager.even_bus.emit_card_drawn(drawn_card, self)
		else:
			print("Not your turn, cannot draw card")
			pass
	
func draw_card():
	if deck.is_empty():
		push_warning("Deck is empty")
		return null

	var target_world_pos = player_field.position + player_field.basis.z + Vector3.UP
	var card_node = deck_zone.get_node("TopCard")
	var tween = create_tween()
	tween.tween_property(card_node, "global_position", target_world_pos, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	target_world_pos = deck_zone.get_node("Stack/TopMarker").global_position
	card_node.global_position = target_world_pos

	var card_data = deck.pop_front()
	hand.append(card_data)
	var card = player_ui.get_node("HBoxContainer/Hand").add_card(card_data)
	card.set_meta("set", card_data["set"])
	card.set_meta("id", card_data["id"])
	card.connect("clicked", func(clicked): _on_card_clicked(clicked))

	return card_data


func _on_card_clicked(card: TextureButton):
	if !my_turn || clicks <= 0: 
		push_warning("Trying to play card off turn")
		return
	
	var hand_ui = player_ui.get_node("HBoxContainer/Hand")
	await hand_ui.play_card(card)

	var card_data = CardDatabase.get_card_by_set_and_id(card.get_meta("set"), card.get_meta("id"))
	state.play_card(card_data)


func play_card(card: Dictionary, destination):
	var card_set = card["deck"]["set"]
	var card_id = card["deck"]["id"]
	var path = "res://cards/art/%s/%d.jpg" % [card_set, card_id]
	var texture = load(path)
	var card3d = preload("res://cards/card3d.tscn").instantiate()
	card3d.set_meta("set", card_set)
	card3d.set_meta("id", card_id)
	card3d.material_override = card3d.material_override.duplicate()
	card3d.material_override.set_shader_parameter("front_tex", texture)

	if destination is String:
		destination = player_field.get_node(destination)
	
	destination.add_child(card3d)
	card3d.rotation_degrees = Vector3(0,0,0)
	var offset = (destination.get_child_count()-1) * -0.4
	card3d.position = Vector3(offset, 0, 0)


func trash_card(card: TextureButton):
	trash.append({"set": card.get_meta("set"), "id": int(card.get_meta("id"))})

	var path = "res://cards/art/%s/%d.jpg" % [card.get_meta("set"), card.get_meta("id")]
	var texture = load(path)
	
	if !trash_zone.visible:
		trash_zone.visible = true
	var top_card = trash_zone.get_node("TopCard")
	top_card.material_override.set_shader_parameter("front_tex", texture)
