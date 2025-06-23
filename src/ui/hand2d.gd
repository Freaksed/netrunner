extends Panel

var cards: Array[Control] = []

const lift_amount = 30
const grow_to = Vector2(1.1,1.1)
var card_original_position = Vector2.ZERO
var card_original_scale = Vector2.ONE
var card_original_z = -1

func add_card(card_data: Dictionary) -> TextureButton:
	var card := CardDatabase.card2d.instantiate()
	card.mouse_entered.connect(lift_card.bind(card))
	card.mouse_exited.connect(return_card.bind(card))
	card.custom_minimum_size = card.size
	card.init_from_json(card_data)
	cards.append(card)
	add_child(card)
	layout_hand()
	return card


func layout_hand():
	var center = size /2
	var radius = 300
	var angle_range = deg_to_rad(50)
	
	var count = cards.size()
	for i in range(count):
		var card = cards[i]
		var t = float(i) / float(max(1, count - 1))  # normalized 0–1
		var angle = lerp(-angle_range / 2.0, angle_range / 2.0, t)

		var x = center.x + radius * sin(angle) - card.size.x / 2
		var y = radius * (1 - cos(angle))
		var target_pos = Vector2(x,y+50)
		
		var tween = create_tween()
		if i == count-1:
			card.position = Vector2(size.x/2, size.y)
			card.rotation = 0
		tween.tween_property(card, "position", target_pos, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(card, "rotation", angle, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func lift_card(card: TextureButton):
	card_original_position = card.position
	card_original_scale = card.scale
	card_original_z = card.z_index
	
	card.z_index = 999
	if card.tween: card.tween.kill()
	card.tween = create_tween()
	card.tween.tween_property(card, "position", card_original_position - Vector2(0, lift_amount), 0.15)
	card.tween.parallel().tween_property(card, "scale", grow_to, 0.15)


func return_card(card: TextureButton):
	card.z_index = card_original_z
	if card.tween: card.tween.kill()
	card.tween = create_tween()
	card.tween.tween_property(card, "position", card_original_position, 0.15)
	card.tween.parallel().tween_property(card, "scale", card_original_scale, 0.15)


func remove_card(card: Control):
	if card in cards:
		cards.erase(card)
		card.queue_free()


func clear():
	for card in cards:
		card.queue_free()
	cards.clear()
