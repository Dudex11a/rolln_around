@tool
extends EditorPlugin
class_name Vector3Debug


const VECTOR3_DISPLAY_RES: PackedScene = preload("res://addons/vector3_debug/vector3_display.tscn")

static var display_world: Node = null
static var position_node: Node3D = null


static func display_vector(
	vector: Vector3,
	position: Vector3 = position_node.global_position,
	vec_scale: float = 1.0,
	duration: float = 0.0,
	world: Node = display_world
) -> void:
	var vector3_display: Vector3DebugDisplay = VECTOR3_DISPLAY_RES.instantiate()
	world.add_child(vector3_display)
	vector3_display.global_position = position
	vector3_display.set_vector(vector, vec_scale)
	if duration > 0.0:
		vector3_display.destroy_timer_ref.wait_time = duration
		vector3_display.destroy_timer_ref.start()
