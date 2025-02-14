extends RigidBody3D
class_name Player


signal input(event: InputEvent)
signal force(state: PhysicsDirectBodyState3D)

const default_force_speed: float = 925.0
const default_torque_speed: float = 700.0
const linear_velocity_modifier_max_speed_cutoff: float = 8
const angular_velocity_modifier_max_speed_cutoff: float = 12
const linear_low_end_modifier: float = 0.5
const angular_low_end_modifier: float = 0.1
const target_raycast_position: = Vector3(0, -3.0, 0)
const wall_detection_distance: float = 0.7
const IS_WALL_AMOUNT: float = 1.1780972451
# Have a curve to interpolate the modifier value
# Have the velocity_modifier (at 0) quickly transition into allowing for more
# control (at 1 is full control but starting at 0.12 the Player will have more
# control than if I just did a linear lerp).
@export var modifier_modifier_curve: Curve

var disabled: bool = false:
	set(value):
		disabled = value
		freeze = disabled
		collision_shape_ref.disabled = disabled

var horizontal_raycasts: Array[RayCast3D] = []
var move_input: = Vector2.ZERO
var is_colliding: bool = false
var up_direction: = Vector3(0.0, 1.0, 0.0)
var recent_floor_normal: = Vector3.ZERO
var recent_wall_normal: = Vector3.ZERO
var recent_normal: = Vector3.ZERO

@onready var recent_wall_touch_timer_ref: Timer = %RecentWallTouchTimer
@onready var player_location_ref: Node3D = %PlayerLocation
@onready var jump_ring_animation_player_ref: AnimationPlayer = %JumpRingAnimationPlayer
@onready var collision_shape_ref: CollisionShape3D = $CollisionShape
@onready var floor_raycast_ref: RayCast3D = %FloorRayCast


func _input(event: InputEvent) -> void:
	input.emit(event)

func get_linear_velocity_2d() -> Vector2:
	return Vector2(linear_velocity.x, linear_velocity.z)
	
func get_angular_velocity_2d() -> Vector2:
	return Vector2(angular_velocity.x, angular_velocity.z)

func modifier_calc(velocity_2d: Vector2, modifier_max_speed_cutoff: float, low_end_modifier: float) -> float:
	# Calculate modifiers, here are some example calculations for better understanding
	# Assuming modifier_max_speed_cutoff = 8 and low_end_modifier = 0.5
	# 8-linear_velocity_2d = 0.5-force_modifier
	# 6-linear_velocity_2d = 0.5-force_modifier
	# 3-linear_velocity_2d =  0.75-force_modifier
	# 0-linear_velocity_2d = 1.0-force_modifier
	return lerp(low_end_modifier, 1.0, max(-(min(velocity_2d.length() / modifier_max_speed_cutoff, 1.0) - 1), 0.0))


func is_on_floor() -> bool:
	return floor_raycast_ref.is_colliding()


func is_moving_up() -> bool:
	return linear_velocity.angle_to(up_direction) < PI * 0.25


func _physics_process(delta: float) -> void:
	# Movement
	move_input = Input.get_vector("player_left", "player_right", "player_up", "player_down", 0.1)
	# Rotate move_input by camera rotation in tree
	var y_rot: float = -RA.world_camera_ref.rotation.y
	move_input = move_input.rotated(y_rot)
	# Create velocity modifier that becomes less the faster you go
	# so you have fast acceleration but you don't go crazy fast
	# after the initial acceleration
	var linear_velocity_2d: Vector2 = get_linear_velocity_2d()
	var angular_velocity_2d: Vector2 = get_angular_velocity_2d()
	var force_modifier: float = modifier_calc(linear_velocity_2d, linear_velocity_modifier_max_speed_cutoff, linear_low_end_modifier)
	var torque_modifier: float = modifier_calc(angular_velocity_2d, angular_velocity_modifier_max_speed_cutoff, angular_low_end_modifier)
	# Adjust modifiers based on force/torque compared to direction held
	var modifier_modifier: float = (abs(abs(linear_velocity_2d.angle()) - abs(move_input.angle()))) / PI
	# Apply curve to modifier_modifier
	modifier_modifier = modifier_modifier_curve.sample(modifier_modifier)
	# Finalize modifiers
	force_modifier = lerp(force_modifier, 1.0, modifier_modifier)
	torque_modifier = lerp(torque_modifier, 1.0, modifier_modifier)
	# Apply move_input
	var move_force: = Vector3(move_input.x, 0, move_input.y) * delta * default_force_speed * force_modifier
	var torque: = Vector3(move_input.y, 0, -move_input.x) * delta * default_torque_speed * torque_modifier
	if not is_colliding:
		# In air apply airial drift
		apply_force(move_force)
		# Apply torque but less in air ~~~
		apply_torque(torque / 3)
	else:
		apply_torque(torque)
	# Match player's world position to PlayerLocation
	if is_instance_valid(player_location_ref):
		player_location_ref.global_position = global_position


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	# Collision
	var contact_count: int = state.get_contact_count()
	for i in contact_count:
		contact(state, i)
	is_colliding = contact_count > 0
	force.emit(state)


func get_distance_from_horizontal(normal: Vector3) -> float:
	return abs(normal.angle_to(up_direction) - normal.angle_to(-up_direction))


func _is_normal_a_wall(normal: Vector3) -> bool:
	return get_distance_from_horizontal(normal) < IS_WALL_AMOUNT


func contact(state: PhysicsDirectBodyState3D, index: int) -> void:
	var normal: Vector3 = state.get_contact_local_normal(index)
	if _is_normal_a_wall(normal):
		recent_wall_touch_timer_ref.start()
		recent_wall_normal = normal
		recent_normal = recent_wall_normal
	else:
		if floor_raycast_ref.is_colliding():
			recent_floor_normal = floor_raycast_ref.get_collision_normal()
		else:
			recent_floor_normal = normal
		recent_normal = recent_floor_normal


# TODO Remove this old code
#func contact(state: PhysicsDirectBodyState3D, index: int) -> void:
	#var normal: Vector3 = state.get_contact_local_normal(index)
	#if _is_normal_a_wall(normal):
		#recent_wall_touch_timer_ref.start()
		#recent_wall_normal = normal
	#else:
		#if floor_raycast_ref.is_colliding():
			#recent_floor_normal = floor_raycast_ref.get_collision_normal()
		#else:
			#recent_floor_normal = normal


func _on_recent_wall_touch_timer_timeout() -> void:
	recent_wall_normal = Vector3.ZERO
