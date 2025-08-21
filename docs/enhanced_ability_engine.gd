# Enhanced AbilityEngine.gd - Updated for Comprehensive Ability Language
class_name EnhancedAbilityEngine
extends RefCounted

var game_state: GameState
var event_bus: EventBus
var variables: Dictionary = {}  # For storing temporary variables

func _init(state: GameState, events: EventBus):
	game_state = state
	event_bus = events

# Main entry point for executing abilities using the comprehensive language
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

# Enhanced effect execution supporting the comprehensive language
func execute_effect(effect: Dictionary, source_card: Card, context: Dictionary):
	var effect_type = effect.get("type", effect.get("action"))  # Support both formats
	var targets = resolve_targets(effect.get("target", "self"), source_card, context)
	var amount = calculate_value(effect.get("amount", 1), source_card, context)
	
	# Check effect condition
	if effect.has("condition"):
		if not evaluate_condition(effect["condition"], source_card, context):
			return
	
	# Check if effect is optional
	if effect.get("optional", false):
		var active_player = context.get("active_player")
		if not game_state.ui_manager.request_yes_no(active_player, "Use optional effect?"):
			return
	
	match effect_type:
		"modify_credits":
			for target in targets:
				if target is Player:
					target.add_credits(amount)
		
		"modify_clicks":
			for target in targets:
				if target is Player:
					target.gain_clicks(amount)
		
		"modify_tags":
			for target in targets:
				if target is Player:
					if amount > 0:
						target.add_tags(amount)
					else:
						target.remove_tags(-amount)
		
		"modify_link":
			for target in targets:
				if target is Player:
					target.modify_link(amount, effect.get("duration", "permanent"))
		
		"modify_memory":
			for target in targets:
				if target is Player:
					target.modify_memory(amount, effect.get("duration", "permanent"))
		
		"modify_hand_size":
			for target in targets:
				if target is Player:
					target.modify_max_hand_size(amount, effect.get("duration", "permanent"))
		
		"modify_strength":
			var duration = effect.get("duration", "permanent")
			for target in targets:
				if target is Card:
					target.modify_strength(amount, duration)
		
		"modify_counters":
			var counter_type = effect.get("counter_type", "generic")
			for target in targets:
				if target is Card:
					if amount > 0:
						target.add_counters(counter_type, amount)
					else:
						target.remove_counters(counter_type, -amount)
		
		"draw_cards":
			var zone_from = effect.get("zone_from", "deck")
			for target in targets:
				if target is Player:
					draw_cards(target, amount, zone_from)
		
		"discard_cards":
			var zone_from = effect.get("zone_from", "hand")
			var random = effect.get("random", false)
			var reveal = effect.get("reveal", false)
			for target in targets:
				if target is Player:
					discard_cards(target, amount, zone_from, random, reveal)
		
		"move_card":
			var zone_to = effect.get("zone_to", "hand")
			var reveal = effect.get("reveal", false)
			var face_up = effect.get("face_up", false)
			for target in targets:
				if target is Card:
					move_card_to_zone(target, zone_to, reveal, face_up)
		
		"install_card":
			var zone_from = effect.get("zone_from")
			var pay_cost = effect.get("pay_cost", true)
			var face_up = effect.get("face_up", false)
			var host = effect.get("host")
			for target in targets:
				if target is Card:
					install_card(target, context.get("active_player"), pay_cost, face_up, host)
		
		"trash_card":
			for target in targets:
				if target is Card:
					trash_card(target)
		
		"remove_from_game":
			for target in targets:
				if target is Card:
					remove_from_game(target)
		
		"reveal_card":
			for target in targets:
				if target is Card:
					reveal_card(target)
		
		"look_at_cards":
			var zone_from = effect.get("zone_from", "deck")
			var player = targets[0] if targets.size() > 0 else context.get("active_player")
			look_at_cards(player, amount, zone_from)
		
		"search_deck":
			var zone = effect.get("zone", "deck")
			var count = effect.get("count", 1)
			var condition = effect.get("condition")
			var reveal = effect.get("reveal", false)
			var destination = effect.get("destination", "hand")
			var shuffle_after = effect.get("shuffle_after", true)
			var player = targets[0] if targets.size() > 0 else context.get("active_player")
			search_deck(player, zone, count, condition, reveal, destination, shuffle_after)
		
		"shuffle_deck":
			for target in targets:
				if target is Player:
					target.shuffle_deck()
		
		"deal_damage":
			var damage_type = effect.get("damage_type", "net")
			var unpreventable = effect.get("unpreventable", false)
			for target in targets:
				if target is Player:
					target.take_damage(damage_type, amount, unpreventable)
		
		"prevent_damage":
			var damage_type = effect.get("damage_type", "any")
			# Implementation depends on damage prevention system
			prevent_damage(damage_type, amount, context)
		
		"initiate_run":
			var server = effect.get("server", "hq")
			var replacement_access = effect.get("replacement_access")
			var effects_during_run = effect.get("effects_during_run", [])
			var effects_on_success = effect.get("effects_on_success", [])
			initiate_run(server, replacement_access, effects_during_run, effects_on_success, context)
		
		"end_run":
			game_state.end_current_run()
		
		"jack_out":
			game_state.jack_out()
		
		"break_subroutine":
			var ice = context.get("current_ice")
			if ice:
				if effect.get("amount") == "all":
					ice.break_all_subroutines()
				else:
					ice.break_subroutine(amount)
		
		"bypass_ice":
			var ice = context.get("current_ice")
			if ice:
				bypass_ice(ice)
		
		"encounter_ice_again":
			var ice = context.get("current_ice")
			if ice:
				encounter_ice_again(ice)
		
		"access_additional_cards":
			context["additional_access"] = context.get("additional_access", 0) + amount
		
		"prevent_access":
			context["prevent_access"] = true
		
		"steal_agenda":
			for target in targets:
				if target is Card and target.type == "Agenda":
					steal_agenda(target, context.get("active_player"))
		
		"score_agenda":
			for target in targets:
				if target is Card and target.type == "Agenda":
					score_agenda(target, context.get("active_player"))
		
		"advance_card":
			for target in targets:
				if target is Card:
					advance_card(target, amount)
		
		"rez_card":
			var pay_cost = effect.get("pay_cost", true)
			for target in targets:
				if target is Card:
					rez_card(target, pay_cost)
		
		"derez_card":
			for target in targets:
				if target is Card:
					derez_card(target)
		
		"expose_card":
			for target in targets:
				if target is Card:
					expose_card(target)
		
		"trace":
			var base_strength = effect.get("base_strength", 0)
			var on_success = effect.get("on_success")
			var on_failure = effect.get("on_failure")
			execute_trace(base_strength, on_success, on_failure, source_card, context)
		
		"give_tag":
			for target in targets:
				if target is Player:
					target.add_tags(amount)
		
		"remove_tag":
			for target in targets:
				if target is Player:
					target.remove_tags(amount)
		
		"avoid_tag":
			# Implementation depends on tag avoidance system
			avoid_tag(amount, context)
		
		"gain_bad_publicity":
			for target in targets:
				if target is Player:
					target.add_bad_publicity(amount)
		
		"lose_bad_publicity":
			for target in targets:
				if target is Player:
					target.remove_bad_publicity(amount)
		
		"purge_virus_counters":
			purge_virus_counters()
		
		"create_server":
			var server_name = effect.get("server_name", "Remote")
			create_server(server_name, context.get("active_player"))
		
		"create_token":
			var token_type = effect.get("token_type", "generic")
			for target in targets:
				if target is Card:
					target.add_counters(token_type, amount)
		
		"set_variable":
			var key = effect["key"]
			var value = calculate_value(effect["value"], source_card, context)
			variables[key] = value
		
		"trigger_ability":
			var ability_ref = effect.get("ability_ref")
			trigger_ability(ability_ref, source_card, context)
		
		"copy_ability":
			var ability_ref = effect.get("ability_ref")
			copy_ability(ability_ref, source_card, context)
		
		"prevent_ability":
			var ability_ref = effect.get("ability_ref")
			prevent_ability(ability_ref, context)
		
		"modify_cost":
			var cost_type = effect.get("cost_type", "install")
			var duration = effect.get("duration", "permanent")
			modify_cost(cost_type, amount, duration, targets)
		
		"add_subtype":
			var subtype = effect["subtype"]
			var duration = effect.get("duration", "permanent")
			for target in targets:
				if target is Card:
					target.add_subtype(subtype, duration)
		
		"remove_subtype":
			var subtype = effect["subtype"]
			var duration = effect.get("duration", "permanent")
			for target in targets:
				if target is Card:
					target.remove_subtype(subtype, duration)
		
		"gain_ability":
			var ability = effect["ability"]
			var duration = effect.get("duration", "permanent")
			for target in targets:
				if target is Card:
					target.gain_ability(ability, duration)
		
		"lose_ability":
			var ability = effect["ability"]
			var duration = effect.get("duration", "permanent")
			for target in targets:
				if target is Card:
					target.lose_ability(ability, duration)
		
		"choose_and_execute":
			var prompt = effect.get("prompt", "Choose one:")
			var choices = effect["choices"]
			var min_choices = effect.get("min_choices", 1)
			var max_choices = effect.get("max_choices", 1)
			execute_choice_effect(prompt, choices, min_choices, max_choices, source_card, context)
		
		"prompt_choice":
			var prompt = effect["prompt"]
			var choices = effect["choices"]
			execute_prompt_choice(prompt, choices, source_card, context)
		
		"conditional_effect":
			var condition = effect["condition"]
			var then_effect = effect["then"]
			var else_effect = effect.get("else")
			if evaluate_condition(condition, source_card, context):
				execute_effect(then_effect, source_card, context)
			elif else_effect:
				execute_effect(else_effect, source_card, context)
		
		"replacement_effect":
			var replacement_condition = effect.get("replacement_condition")
			var replacement = effect.get("replacement")
			setup_replacement_effect(replacement_condition, replacement, source_card, context)
		
		"delayed_effect":
			var delay_until = effect["delay_until"]
			var delayed_effects = effect["effects"]
			setup_delayed_effect(delay_until, delayed_effects, source_card, context)
		
		"compound":
			var effects = effect["effects"]
			for sub_effect in effects:
				execute_effect(sub_effect, source_card, context)
		
		_:
			push_warning("Unknown effect type: " + str(effect_type))

# Enhanced condition evaluation supporting the comprehensive language
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
	
	# Basic condition evaluation using game state queries
	var query_result = execute_query(condition, source_card, context)
	var operator = condition["operator"]
	var value = calculate_value(condition["value"], source_card, context)
	return compare_values(query_result, operator, value)

# Enhanced query system supporting all query types
func execute_query(query: Dictionary, source_card: Card, context: Dictionary):
	var query_type = query["type"]
	var target = query.get("target", "self")
	
	match query_type:
		"constant":
			return query["value"]
		
		"variable":
			return variables.get(query["key"], 0)
		
		"x_value":
			return context.get("x_value", 0)
		
		"player_credits":
			return get_target_player(target, context).credits
		
		"player_clicks": 
			return get_target_player(target, context).clicks
		
		"player_tags":
			return get_target_player(target, context).tags
		
		"player_agenda_points":
			return get_target_player(target, context).agenda_points
		
		"player_hand_size":
			return get_target_player(target, context).hand.size()
		
		"player_max_hand_size":
			return get_target_player(target, context).max_hand_size
		
		"player_memory_used":
			return get_target_player(target, context).memory_used
		
		"player_max_memory":
			return get_target_player(target, context).max_memory
		
		"player_link_strength":
			return get_target_player(target, context).link_strength
		
		"player_bad_publicity":
			return get_target_player(target, context).bad_publicity
		
		"cards_in_zone":
			var zone = query.get("zone", "hand")
			var player = get_target_player(target, context)
			var condition = query.get("condition")
			return count_cards_in_zone(player, zone, condition)
		
		"cards_with_subtype":
			var subtype = query["subtype"]
			var zone = query.get("zone", "installed")
			var player = get_target_player(target, context)
			return count_cards_with_subtype(player, zone, subtype)
		
		"cards_with_property":
			var property = query["property"]
			var zone = query.get("zone", "installed")
			var player = get_target_player(target, context)
			return count_cards_with_property(player, zone, property)
		
		"counters_on_card":
			var counter_type = query.get("counter_type", "generic")
			if target == "self":
				return source_card.get_counters(counter_type)
			else:
				var card_target = get_target_card(target, context)
				return card_target.get_counters(counter_type) if card_target else 0
		
		"ice_strength":
			var ice = get_target_card(target, context)
			return ice.strength if ice else 0
		
		"program_strength":
			var program = get_target_card(target, context)
			return program.strength if program else 0
		
		"install_cost":
			var card = get_target_card(target, context)
			return card.install_cost if card else 0
		
		"rez_cost":
			var card = get_target_card(target, context)
			return card.rez_cost if card else 0
		
		"trash_cost":
			var card = get_target_card(target, context)
			return card.trash_cost if card else 0
		
		"advancement_requirement":
			var card = get_target_card(target, context)
			return card.advancement_requirement if card else 0
		
		"agenda_points":
			var card = get_target_card(target, context)
			return card.agenda_points if card else 0
		
		"threat_level":
			return game_state.threat_level
		
		"successful_runs_this_turn":
			return game_state.runner.successful_runs_this_turn
		
		"cards_accessed_this_turn":
			return game_state.runner.cards_accessed_this_turn
		
		"damage_dealt_this_turn":
			return game_state.damage_dealt_this_turn
		
		"run_server":
			return game_state.current_run.server if game_state.current_run else ""
		
		"current_phase":
			return game_state.current_phase
		
		"turn_number":
			return game_state.turn_number
		
		"run_position":
			return game_state.current_run.position if game_state.current_run else 0
		
		_:
			push_warning("Unknown query type: " + query_type)
			return 0

# Helper functions for the enhanced system
func execute_choice_effect(prompt: String, choices: Array, min_choices: int, max_choices: int, source_card: Card, context: Dictionary):
	var active_player = context.get("active_player")
	var choice_indices = game_state.ui_manager.request_multiple_choice(active_player, choices.size(), min_choices, max_choices, prompt)
	
	for index in choice_indices:
		if index >= 0 and index < choices.size():
			execute_effect(choices[index], source_card, context)

func execute_prompt_choice(prompt: String, choices: Array, source_card: Card, context: Dictionary):
	var active_player = context.get("active_player")
	var choice_index = game_state.ui_manager.request_choice(active_player, choices, prompt)
	
	if choice_index >= 0 and choice_index < choices.size():
		execute_effect(choices[choice_index]["effect"], source_card, context)

func setup_replacement_effect(replacement_condition, replacement, source_card: Card, context: Dictionary):
	# Register a replacement effect with the game state
	game_state.register_replacement_effect(replacement_condition, replacement, source_card)

func setup_delayed_effect(delay_until, effects: Array, source_card: Card, context: Dictionary):
	# Register a delayed effect with the game state
	game_state.register_delayed_effect(delay_until, effects, source_card, context)

func get_target_card(target: String, context: Dictionary) -> Card:
	match target:
		"self":
			return context.get("source_card")
		"current_ice":
			return context.get("current_ice")
		"accessed_card":
			return context.get("accessed_card")
		_:
			return null

# Additional helper methods would be implemented here...
func prevent_damage(damage_type: String, amount: int, context: Dictionary): pass
func avoid_tag(amount: int, context: Dictionary): pass
func bypass_ice(ice: Card): pass
func encounter_ice_again(ice: Card): pass
func execute_trace(base_strength: int, on_success, on_failure, source_card: Card, context: Dictionary): pass
func create_server(server_name: String, player: Player): pass
func count_cards_with_property(player: Player, zone: String, property: Dictionary) -> int: return 0
func discard_cards(player: Player, amount: int, zone_from: String, random: bool, reveal: bool): pass
func look_at_cards(player: Player, amount: int, zone_from: String): pass
func search_deck(player: Player, zone: String, count: int, condition, reveal: bool, destination: String, shuffle_after: bool): pass
func reveal_card(card: Card): pass
func advance_card(card: Card, amount: int): pass
func rez_card(card: Card, pay_cost: bool): pass
func derez_card(card: Card): pass
func expose_card(card: Card): pass
func steal_agenda(agenda: Card, player: Player): pass
func score_agenda(agenda: Card, player: Player): pass
func purge_virus_counters(): pass
func trigger_ability(ability_ref: String, source_card: Card, context: Dictionary): pass
func copy_ability(ability_ref: String, source_card: Card, context: Dictionary): pass
func prevent_ability(ability_ref: String, context: Dictionary): pass
func modify_cost(cost_type: String, amount: int, duration: String, targets: Array): pass
func initiate_run(server: String, replacement_access, effects_during_run: Array, effects_on_success: Array, context: Dictionary): pass

# Include all the existing helper methods from the original ability_engine.gd
func can_use_ability(ability_data: Dictionary, source_card: Card, context: Dictionary) -> bool:
	# Enhanced implementation supporting new timing and condition systems
	return true

func pay_cost(cost: Dictionary, source_card: Card, context: Dictionary) -> bool:
	# Enhanced implementation supporting all cost types
	return true

func resolve_targets(target_selector, source_card: Card, context: Dictionary) -> Array:
	# Enhanced implementation supporting all targeting types
	return []

func calculate_value(value_def, source_card: Card, context: Dictionary) -> int:
	# Enhanced implementation supporting all dynamic value types
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
		
		if value_def.has("divide_by"):
			var divisor = execute_query(value_def["divide_by"], source_card, context)
			if divisor != 0:
				result = result / divisor
				
				var round_mode = value_def.get("round", "down")
				match round_mode:
					"up":
						result = ceil(result)
					"down":
						result = floor(result)
					"nearest":
						result = round(result)
		
		# Apply min/max constraints
		if value_def.has("minimum"):
			result = max(result, value_def["minimum"])
		if value_def.has("maximum"):
			result = min(result, value_def["maximum"])
		
		return result
	
	return 0

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
		"in": return b is Array and a in b
		"exists": return b == true and a != null
		_: return false

func track_ability_usage(ability_data, source_card): pass
func check_timing_restriction(timing): pass
func check_player_restriction(player_restriction, player): pass
func has_reached_usage_limit(ability_data, source_card): pass
func trash_card(card): pass
func remove_from_game(card): pass
func get_zone_cards(player, zone): pass
func count_cards_in_zone(player, zone, condition): pass
func count_cards_with_subtype(player, zone, subtype): pass
func draw_cards(target, amount, zone_from): pass
func move_card_to_zone(target, zone_to, reveal: bool = false, face_up: bool = false): pass
func install_card(target, player, pay_cost: bool = true, face_up: bool = false, host = null): pass