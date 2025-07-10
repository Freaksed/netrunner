# AbilityEngine.gd - Executes JSON-defined card abilities
class_name AbilityEngine
extends RefCounted

var game_state: GameState
var event_bus: EventBus

func _init(state: GameState, events: EventBus):
	game_state = state
	event_bus = events

# Main entry point for executing abilities
func execute_ability(ability_data: Dictionary, source_card: Card, context: Dictionary = {}):
	if not can_use_ability(ability_data, source_card, context):
		return false
	
	# Pay costs for paid abilities
	if ability_data.get("type") == "paid":
		if not pay_cost(ability_data.get("cost", {}), source_card, context):
			return false
	
	# Execute all effects
	for effect in ability_data.get("effects", []):
		execute_effect(effect, source_card, context)
	
	# Track usage for limited abilities
	track_ability_usage(ability_data, source_card)
	return true

# Check if ability can be used
func can_use_ability(ability_data: Dictionary, source_card: Card, context: Dictionary) -> bool:
	# Check timing restrictions
	var timing = ability_data.get("timing_restriction", "any")
	if not check_timing_restriction(timing):
		return false
	
	# Check player restrictions
	var player_restriction = ability_data.get("player_restriction", "any")
	if not check_player_restriction(player_restriction, context.get("active_player")):
		return false
	
	# Check usage limits
	if has_reached_usage_limit(ability_data, source_card):
		return false
	
	# Check conditions
	if ability_data.has("condition"):
		return evaluate_condition(ability_data["condition"], source_card, context)
	
	return true

# Evaluate conditions recursively
func evaluate_condition(condition: Dictionary, source_card: Card, context: Dictionary) -> bool:
	if condition.has("and"):
		for sub_condition in condition["and"]:
			if not evaluate_condition(sub_condition, source_card, context):
				return false
		return true
	
	if condition.has("or"):
		for sub_condition in condition["or"]:
			if evaluate_condition(sub_condition, source_card, context):
				return true
		return false
	
	if condition.has("not"):
		return not evaluate_condition(condition["not"], source_card, context)
	
	# Basic condition evaluation
	var query_result = execute_query(condition["query"], source_card, context)
	return compare_values(query_result, condition["operator"], condition["value"])

# Query game state for values
func execute_query(query: Dictionary, source_card: Card, context: Dictionary):
	var query_type = query["type"]
	var target = query.get("target", "self")
	
	match query_type:
		"player_credits":
			return get_target_player(target, context).credits
		"player_clicks": 
			return get_target_player(target, context).clicks
		"player_cards_in_hand":
			return get_target_player(target, context).hand.size()
		"tags_count":
			return game_state.runner.tags
		"cards_in_zone":
			var zone = query.get("zone", "hand")
			var player = get_target_player(target, context)
			return get_zone_cards(player, zone).size()
		"cards_with_subtype":
			var subtype = query["subtype"]
			var zone = query.get("zone", "installed")
			var player = get_target_player(target, context)
			return count_cards_with_subtype(player, zone, subtype)
		"counters_on_card":
			var counter_type = query.get("counter_type", "generic")
			if target == "self":
				return source_card.get_counters(counter_type)
			# Handle other targets...
		"agenda_points":
			return get_target_player(target, context).agenda_points
		_:
			push_warning("Unknown query type: " + query_type)
			return 0

# Execute individual effects
func execute_effect(effect: Dictionary, source_card: Card, context: Dictionary):
	var action = effect["action"]
	var targets = resolve_targets(effect.get("target", "self"), source_card, context)
	var amount = calculate_value(effect.get("amount", 1), source_card, context)
	
	# Check effect condition
	if effect.has("condition"):
		if not evaluate_condition(effect["condition"], source_card, context):
			return
	
	match action:
		"modify_credits":
			for target in targets:
				if target is Player:
					target.add_credits(amount)
		
		"modify_clicks":
			for target in targets:
				if target is Player:
					target.gain_clicks(amount)
		
		"modify_cards":
			var zone_from = effect.get("zone_from", "deck")
			for target in targets:
				if target is Player:
					draw_cards(target, amount, zone_from)
		
		"take_damage":
			var damage_type = effect.get("damage_type", "net")
			for target in targets:
				if target is Player:
					target.take_damage(damage_type, amount)
		
		"move_card":
			var zone_to = effect.get("zone_to", "hand")
			for target in targets:
				if target is Card:
					move_card_to_zone(target, zone_to)
		
		"install_card":
			var face_up = effect.get("face_up", false)
			for target in targets:
				if target is Card:
					install_card(target, context.get("active_player"), face_up)
		
		"initiate_run":
			var server = effect.get("server", "hq")
			game_state.initiate_run(server, context.get("active_player"))
		
		"end_run":
			game_state.end_current_run()
		
		"choose_and_execute":
			var choices = effect.get("choices", [])
			var allow_both = effect.get("allow_both_if_condition", false)
			handle_choice_effect(choices, source_card, context, allow_both, effect.get("condition"))
		
		"trash_card":
			for target in targets:
				if target is Card:
					trash_card(target)
		
		"add_tag":
			if game_state.runner in targets:
				game_state.runner.add_tags(amount)
		
		"remove_tag":
			if game_state.runner in targets:
				game_state.runner.remove_tags(amount)
		
		"break_subroutine":
			var ice = context.get("current_ice")
			if ice:
				ice.break_subroutine(amount)
		
		"search_deck":
			var player = targets[0] if targets.size() > 0 else context.get("active_player")
			search_deck(player, effect)
		
		"shuffle_deck":
			for target in targets:
				if target is Player:
					target.shuffle_deck()
		
		"create_token":
			var counter_type = effect.get("counter_type", "generic")
			for target in targets:
				if target is Card:
					target.add_counters(counter_type, amount)
		
		_:
			push_warning("Unknown effect action: " + action)

# Resolve target selectors to actual game objects
func resolve_targets(target_selector, source_card: Card, context: Dictionary) -> Array:
	if target_selector is String:
		match target_selector:
			"corp":
				return [game_state.corp]
			"runner":
				return [game_state.runner]
			"self":
				return [source_card]
			"host":
				return [source_card.host] if source_card.host else []
			_:
				return []
	
	if target_selector is Dictionary:
		var selector_type = target_selector["type"]
		match selector_type:
			"player_choice":
				return handle_player_choice_target(target_selector, context)
			"cards_in_zone":
				return get_cards_in_zone_matching(target_selector)
			"cards_with_subtype":
				return get_cards_with_subtype_matching(target_selector)
			"random_selection":
				var all_matches = get_all_matching_targets(target_selector)
				var count = target_selector.get("count", 1)
				return get_random_selection(all_matches, count)
			_:
				push_warning("Unknown target selector: " + selector_type)
				return []
	
	return []

# Handle player choice targets
func handle_player_choice_target(selector: Dictionary, context: Dictionary) -> Array:
	var zone = selector.get("zone", "hand")
	var count = selector.get("count", 1)
	var prompt = selector.get("prompt", "Choose targets")
	var player = get_target_player(selector.get("player", "active_player"), context)
	
	# This would integrate with your UI system
	var available_targets = get_zone_cards(player, zone)
	return game_state.ui_manager.request_card_choice(player, available_targets, count, prompt)

# Handle choice effects (like Predictive Planogram)
func handle_choice_effect(choices: Array, source_card: Card, context: Dictionary, allow_both: bool = false, condition = null):
	var can_do_both = false
	
	if allow_both and condition:
		can_do_both = evaluate_condition(condition, source_card, context)
	
	if can_do_both:
		# Execute all choices
		for choice in choices:
			execute_effect(choice, source_card, context)
	else:
		# Player chooses one
		var active_player = context.get("active_player")
		var choice_index = game_state.ui_manager.request_choice(active_player, choices.size())
		if choice_index >= 0 and choice_index < choices.size():
			execute_effect(choices[choice_index], source_card, context)

# Calculate dynamic values
func calculate_value(value_def, source_card: Card, context: Dictionary) -> int:
	if value_def is int:
		return value_def
	
	if value_def is Dictionary:
		var base = value_def.get("base", 0)
		var result = base
		
		if value_def.has("multiply_by"):
			var multiplier = execute_query(value_def["multiply_by"], source_card, context)
			result *= multiplier
		
		if value_def.has("add"):
			var addition = execute_query(value_def["add"], source_card, context)
			result += addition
		
		if value_def.has("subtract"):
			var subtraction = execute_query(value_def["subtract"], source_card, context)
			result -= subtraction
		
		# Apply min/max constraints
		if value_def.has("minimum"):
			result = max(result, value_def["minimum"])
		if value_def.has("maximum"):
			result = min(result, value_def["maximum"])
		
		return result
	
	return 0

# Pay costs for paid abilities
func pay_cost(cost: Dictionary, source_card: Card, context: Dictionary) -> bool:
	# Check if cost can be paid
	if not can_pay_cost(cost, source_card, context):
		return false
	
	# Actually pay the costs
	if cost.has("clicks"):
		var amount = calculate_value(cost["clicks"], source_card, context)
		context.get("active_player").use_clicks(amount)
	
	if cost.has("credits"):
		var amount = calculate_value(cost["credits"], source_card, context)
		context.get("active_player").remove_credits(amount)
	
	if cost.has("counters"):
		var counter_data = cost["counters"]
		var counter_type = counter_data["type"]
		var amount = calculate_value(counter_data["amount"], source_card, context)
		var from_targets = resolve_targets(counter_data.get("from", "self"), source_card, context)
		
		for target in from_targets:
			if target is Card:
				target.remove_counters(counter_type, amount)
	
	if cost.has("trash"):
		var trash_targets = resolve_targets(cost["trash"], source_card, context)
		for target in trash_targets:
			if target is Card:
				trash_card(target)
	
	if cost.has("remove_from_game"):
		var remove_targets = resolve_targets(cost["remove_from_game"], source_card, context)
		for target in remove_targets:
			if target is Card:
				remove_from_game(target)
	
	return true

# Helper functions would go here...
func can_pay_cost(cost: Dictionary, source_card: Card, context: Dictionary) -> bool:
	# Implementation for checking if costs can be paid
	return true

func get_target_player(target: String, context: Dictionary) -> Player:
	match target:
		"corp": return game_state.corp
		"runner": return game_state.runner
		"active_player": return context.get("active_player")
		"inactive_player": 
			var active = context.get("active_player")
			return game_state.runner if active == game_state.corp else game_state.corp
		_: return context.get("active_player")

func compare_values(a, operator: String, b) -> bool:
	match operator:
		">=": return a >= b
		"<=": return a <= b
		"==": return a == b
		"!=": return a != b
		">": return a > b
		"<": return a < b
		"contains": return str(a).contains(str(b))
		"not_contains": return not str(a).contains(str(b))
		_: return false

func track_ability_usage(ability_data, source_card): pass
func check_timing_restriction(timing):pass
func check_player_restriction(player_restriction, player):pass
func has_reached_usage_limit(ability_data, source_card):pass
func trash_card(card):pass
func remove_from_game(card):pass

# Additional helper methods for zones, cards, etc. would be implemented here...
func get_zone_cards(player, zone):pass
func count_cards_with_subtype(player, zone, subtype):pass
func get_cards_in_zone_matching(target_selector):pass
func get_cards_with_subtype_matching(target_selector):pass
func get_all_matching_targets(target_selector):pass
func get_random_selection(all_matches, count):pass
func search_deck(player, effect):pass
func draw_cards(target, amount, zone_from):pass
func move_card_to_zone(target, zone_to):pass
func install_card(target, player, face_up):pass
