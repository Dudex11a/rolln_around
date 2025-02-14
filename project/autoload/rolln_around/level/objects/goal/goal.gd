extends Node3D

@onready var confetti_particles: GPUParticles3D = $ConfettiParticles
#@onready @export var world_location: Vector3 = global_transform.origin :
#	set(value):
#		world_location = value
#		if is_inside_tree():
#			set_world_location(value)
@onready var level: Level = G.get_parent_of_type(self, Level)
@onready var geometry_locations: Dictionary = {}

@export var wait_before_results: float = 0.5

var bodys_in_goal: Array[RigidBody3D] = []

#func _ready() -> void:
#	# Get geometry locations
#	for geometry_item in geometry:
#		geometry_locations[geometry_item] = geometry_item.position
#	# Wait until level is ready, then move the geometry
#	await level.ready
#	move_geometry_to_level()

#func move_geometry_to_level() -> void:
#	for geometry_item in geometry:
#		geometry_container.remove_child(geometry_item)
#		level.geometry.call_deferred("add_child", geometry_item)
#	set_world_location()
#
#func set_world_location(location: Vector3 = global_transform.origin) -> void:
#	global_transform.origin = location
#	# Set geometry location as well
#	for geometry_item in geometry:
#		# Check that it exists
#		while not is_instance_valid(geometry_item):
#			await get_tree().process_frame
#		# Check that it's inside a tree
#		while not geometry_item.is_inside_tree():
#			await ready
#		# Move location
#		geometry_item.global_transform.origin = location + geometry_locations[geometry_item]

func dynamic_body_goal(body: RigidBody3D) -> void:
	if not body is Player:
		return
	body = (body as Player)
	# End if body is in goal currently
	if body in bodys_in_goal:
		return
	RA.player_goal_start.emit(body)
	bodys_in_goal.append(body)
	# Confetti!!!
	confetti_particles.emitting = true
	# Wait
	await get_tree().create_timer(wait_before_results, false).timeout
	# Body no longer in goal
	bodys_in_goal.erase(body)
	# If Player
	RA.player_goal.emit(body)


# ----- Signals


func _on_finish_area_body_shape_entered(_body_rid: RID, body: Node3D, _body_shape_index: int, _local_shape_index: int) -> void:
	if body is RigidBody3D:
		dynamic_body_goal(body)
