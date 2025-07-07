extends Panel

var hand: Array[Control] = []

const lift_amount = 100
const grow_to = Vector2(1.5,1.5)

var card_original_position = Vector2.ZERO
var card_original_rotation = Vector2.ZERO
var card_original_scale = Vector2.ONE
var card_original_z = -1

var ready_for_input: bool = false

func add_card(card_data: Dictionary) -> TextureButton:
	var card := CardDatabase.card2d.instantiate()
	card.set_meta("set", card_data["set"])
	card.set_meta("id", int(card_data["id"]))
	
	card.mouse_entered.connect(lift_card.bind(card))
	card.mouse_exited.connect(return_card.bind(card))

	card.custom_minimum_size = card.size
	hand.append(card)
	add_child(card)
	card.position = Vector2(size.x/2, size.y)
	card.rotation = 0
	layout_hand()
	return card


func layout_hand():
	var center = size /2
	var radius = 300
	var angle_range = deg_to_rad(50)
	
	ready_for_input = false
	var count = hand.size()
	# TODO: reenable input after all tweens have completed
	for i in range(count):
		var card = hand[i]

		var t = float(i) / float(max(1, count - 1))  # normalized 0–1
		var angle = lerp(-angle_range / 2.0, angle_range / 2.0, t)

		var x = center.x + radius * sin(angle) - card.size.x / 2
		var y = radius * (1 - cos(angle))
		var target_pos = Vector2(x,y+50)
		
		var tween = create_tween()
		tween.tween_property(card, "position", target_pos, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(card, "rotation", angle, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func lift_card(card: TextureButton):
	if !ready_for_input: return
	card_original_position = card.position
	card_original_rotation = card.rotation
	card_original_scale = card.scale
	card_original_z = card.z_index
	
	card.z_index = 999
	if card.tween: card.tween.kill()
	card.tween = create_tween()
	card.tween.tween_property(card, "position", card_original_position - Vector2(0, lift_amount), 0.15)
	card.tween.parallel().tween_property(card, "rotation", 0.0, 0.15)
	card.tween.parallel().tween_property(card, "scale", grow_to, 0.15)


func return_card(card: TextureButton):
	if !ready_for_input: return
	card.z_index = card_original_z
	if card.tween: card.tween.kill()
	card.tween = create_tween()
	card.tween.tween_property(card, "position", card_original_position, 0.15)
	card.tween.parallel().tween_property(card, "rotation", card_original_rotation, 0.15)
	card.tween.parallel().tween_property(card, "scale", card_original_scale, 0.15)
	

func play_card(card: TextureButton):
	if hand.has(card):
		hand.erase(card)
	var tween = create_tween()
	var target = card.position + Vector2(0, -200)
	var duration = 0.3
	
	tween.tween_property(card, "position", target, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(card, "modulate:a", 0.0, duration)
	
	await tween.finished
	card.queue_free()
	layout_hand()


func clear():
	for card in hand:
		card.queue_free()
	hand.clear()
