class_name Server3D
extends Node3D

@export var is_remote: bool = true
@export var ice_spacing: float = 1.8
@export var max_ice_slots: int = 10

@onready var root := $Root
@onready var ice_track := $IceTrack


func _ready():
	create_ice_positions(3)


func create_ice_positions(count: int):
	for i in range(count):
		add_ice_position()


func add_ice_position() -> Marker3D:
	if ice_track.get_child_count() >= max_ice_slots:
		push_warning("Maximum ICE slots reached")
		return null

	var marker := Marker3D.new()
	marker.name = "IcePosition%d" % (ice_track.get_child_count() + 1)
	marker.position = Vector3(0, 0, -ice_spacing * (ice_track.get_child_count() + 1))
	ice_track.add_child(marker)
	return marker


func get_ice_positions() -> Array[Marker3D]:
	return ice_track.get_children().filter(func(child): return child is Marker3D)


func get_next_ice_position() -> Marker3D:
	return add_ice_position()


func install_ice():
	var marker := get_next_ice_position()
	if marker == null:
		return

	var ice_instance = CardDatabase.card_asset.instantiate()
	marker.add_child(ice_instance)
	ice_instance.position = Vector3.ZERO
	ice_instance.rotation = Vector3.ZERO
