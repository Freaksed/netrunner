extends Node

var stack: Array[String] = []
var current_scene: Node = null

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func push_scene(new_scene: PackedScene):
	if current_scene:
		stack.append(current_scene.scene_file_path)
		current_scene.queue_free()
	current_scene = new_scene.instantiate()
	get_tree().get_root().add_child(current_scene)

func pop_scene():
	if stack.is_empty():
		push_error("Scene stack is empty.")
		return
	var last_scene_path = stack.pop_back()
	var scene = load(last_scene_path)
	if current_scene:
		current_scene.queue_free()
	current_scene = scene.instantiate()
	get_tree().get_root().add_child(current_scene)

func reset_stack(start_scene: PackedScene):
	stack.clear()
	if current_scene:
		current_scene.queue_free()
	current_scene = start_scene.instantiate()
	get_tree().get_root().add_child(current_scene)
