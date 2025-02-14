extends Node3D
class_name BoostPanel

@onready var area: Area3D = $Area3D

@onready var up_axis: Vector3 = rotate_vector_local(Vector3.UP)
@onready var side_axis: Vector3 = rotate_vector_local(Vector3.RIGHT)

@export var scalar: float = 1.0
@export var overwrite_velocity: bool = false
const base_scalar_multiplier: float = 15.0

# How long it takes for 
const time_to_reach_vector: float = 0.4

# ----- Signals

func _on_area_3d_body_shape_entered(_body_rid: RID, body: Node3D, _body_shape_index: int, _local_shape_index: int) -> void:
	# Start launch dynamic body
	if body is RigidBody3D:
		launch(body)

func launch(body: RigidBody3D) -> void:
	var new_up_axis = up_axis
	# Check if launched this body launched recently
	if overwrite_velocity:
		# This will reset the body velocity later down
		new_up_axis = Vector3.ZERO
	# Remove velocity except for up velocity
	# This is for the body will stick to a ramp better instead of bouncing off
	for axis in range(3):
		# Set new velocity to overwrite the up direction or not
		var new_velocity: float = lerp(
			0.0,
			body.linear_velocity[axis],
#			abs(up_axis[axis]) + abs(side_axis[axis]))
			abs(new_up_axis[axis]))
		# Set
		body.linear_velocity[axis] = new_velocity
	# This isn't working but I do want to implement it #!!!TEMP
	# Slow the side velocity down over time
#	# Separate side axis
#	var side_velocity: Vector3 = side_axis * body.linear_velocity
#	# Slow side velocity
#	side_velocity *= get_physics_process_delta_time() * 0.00001
#	# Re-apply the side_velocity in the linear_velocity
#	var inverse_side_axis: Vector3 = abs(abs(side_axis) - (Vector3.ONE * 1))
#	var inverse_side_velocity: Vector3 = inverse_side_axis * body.linear_velocity
#	body.linear_velocity = inverse_side_velocity + side_velocity
		
	# Add launch vector
	body.linear_velocity += get_launch_vector()
	# Rotate angular_velocity to direction
	body.angular_velocity = rotate_vector_local(body.angular_velocity)
	# Launch again if still in area
	
	await get_tree().physics_frame
	if area.overlaps_body(body):
		launch(body)
	
	## Wait a little to remove that the body was launched recently
	#await get_tree().create_timer(0.2).timeout


func get_local_axis() -> Vector3:
	return Quaternion(global_transform.basis).get_axis()


func get_launch_vector() -> Vector3:
	# Set the direction to launch in relation to this node
	var launch_vector: = Vector3.FORWARD
	var launch_axis: Vector3 = get_local_axis()
	# Rotate if there is some rotation
	if not is_equal_approx(launch_axis.length(), 0):
		var angle: float = Quaternion(global_transform.basis).get_angle()
		launch_vector = launch_vector.rotated(launch_axis, angle)
	# Multiply by scalar
	launch_vector *= scalar * base_scalar_multiplier
	# Return
	return launch_vector


func rotate_vector_local(in_vec: Vector3) -> Vector3:
	var out_vec: Vector3 = in_vec
	var launch_axis: Vector3 = get_local_axis()
	if not is_equal_approx(launch_axis.length(), 0):
		var angle: float = Quaternion(global_transform.basis).get_angle()
		out_vec = out_vec.rotated(launch_axis, angle)
	return out_vec
