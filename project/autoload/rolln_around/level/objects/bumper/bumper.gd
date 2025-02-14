## Bounce other nodes away from the Bumper.
extends Node3D
class_name Bumper

## Area3D for detecting Node3D.
@onready var bounce_area: Area3D = $BounceArea
## AnimationPlayer for bounce animation.
@onready var anim_player: AnimationPlayer = $AnimationPlayer
## How strong the launch of the Bumper is.
@export var strength: float = 1.0
## How much to multiply the strength by default so I don't use huge numbers
## for the strength.
const base_strength: float = 15
## How long to wait until to check for the node again.
const wait_duration: float = 0.1
## The axis that the player can be launched in.
## The valid axis are the x and z axis.
const valid_axis: = Vector3(1.0, 0.0, 1.0);

## Bounce [code]node[/code] away from the Bumper.
func bounce_node(node: Node3D) -> void:
	if node is CSGShape3D:
		return
	if node is RigidBody3D:
		# Set new velocity but only on horizontal axis
		var launch_axis: Vector3 = global_position.direction_to(node.global_position)
		var up_dir: Vector3 = get_up_direction()
		var axis: Vector3 = up_dir.cross(launch_axis).normalized()
		var angle: float = up_dir.dot(launch_axis)
		# Rotate the axis halfway towards the horizontal axis
		launch_axis = launch_axis.rotated(axis, angle * 0.5)
		for axis_id in range(3):
			# Set new velocity to overwrite the up direction or not
			var new_velocity: float = lerp(
				0.0,
				node.linear_velocity[axis_id],
				abs(launch_axis[axis_id]))
			# Set
			node.linear_velocity[axis_id] = new_velocity
		node.linear_velocity += launch_axis * strength * base_strength
	# Reset jump on player
	if node is Player:
		node.can_jump = true
	# Play animation
	anim_player.stop()
	anim_player.play("bounce")
	# Wait, then check if the node has left
	await get_tree().create_timer(wait_duration).timeout
	if node in bounce_area.get_overlapping_bodies():
		# Bounce again
		bounce_node(self)


## Rotate [code]in_vec[/code] to correlate the local rotation of the Bumper.
func rotate_vector_local(in_vec: Vector3) -> Vector3:
	var out_vec: Vector3 = in_vec
	var launch_axis: Vector3 = get_local_axis()
	if not is_equal_approx(launch_axis.length(), 0):
		var angle: float = Quaternion(global_transform.basis).get_angle()
		out_vec = out_vec.rotated(launch_axis, angle)
	return out_vec


## Get the local axis.
func get_local_axis() -> Vector3:
	return Quaternion(global_transform.basis).get_axis()


## Get the up direction in relation to the Bumper's rotation.
func get_up_direction() -> Vector3:
	return rotate_vector_local(Vector3.UP)


# ----- Signals


## When [code]body[/code] enters the bounce_area.
func _on_bounce_area_body_shape_entered(_body_rid: RID, body: Node3D, _body_shape_index: int, _local_shape_index: int) -> void:
	bounce_node(body)
