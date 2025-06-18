class_name Ability
extends Node

var condition: Callable
var effect: Callable
var once_per_turn: bool = false
var used_this_turn: bool = false

func try_trigger(context):
    if once_per_turn and used_this_turn:
        return false
    if condition.call(context):
        effect.call(context)
        used_this_turn = true
        return true
    return false

