extends Node3D
class_name Spawn


@onready var spawn_point_ref: Node3D = %SpawnPoint


func get_spawn_point() -> Vector3:
	return spawn_point_ref.global_position
