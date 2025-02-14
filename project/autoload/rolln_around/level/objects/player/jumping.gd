extends Node


const DEFAULT_JUMP_FORCE: float = 9.0
const DEFAULT_HORIZONTAL_JUMP_FORCE: float = 1.25
const DEFAULT_BOUNCE_JUMP_FORCE: float = 10.0
const DEFAULT_HORIZONTAL_BOUNCE_JUMP_FORCE: float = 1.5
const DEFAULT_WALL_JUMP_FORCE: float = 8.0
const INPUT_BUFFER_AMOUNT: float = 1.0

var can_jump: bool = true:
	set(value):
		var old_can_jump: bool = can_jump
		can_jump = value
		if can_jump and not old_can_jump:
			jump_ring_animation_player_ref.stop()
			jump_ring_animation_player_ref.play("regain_jump")
		if not can_jump and old_can_jump:
			jump_ring_animation_player_ref.stop()
			jump_ring_animation_player_ref.play("jump")
var can_short_hop: bool = true
var pressing_jump: bool = false
var holding_jump_to_jump: bool = false

@onready var player_ref: Player = $".."
@onready var jump_ring_animation_player_ref: AnimationPlayer = %JumpRingAnimationPlayer
@onready var jump_buffer_timer_ref: Timer = $JumpBufferTimer
@onready var short_hop_timer_ref: Timer = $ShortHopTimer
@onready var recently_jumped_timer_ref: Timer = $RecentlyJumpedTimer
@onready var no_wall_jump_ray_cast_ref: RayCast3D = %NoWallJumpRayCast


func _ready() -> void:
	player_ref.input.connect(_on_input)
	player_ref.force.connect(_on_force)


#func apply_jump_velocity(
	#jump_force: float = DEFAULT_JUMP_FORCE,
	#horizontal_jump_force: float = DEFAULT_HORIZONTAL_JUMP_FORCE,
#) -> void:
	## Give horizontal boost when jumping (this also allows for b-hopping).
	#if not player_ref.move_input.is_zero_approx():
		#player_ref.apply_central_force(
			#Vector3(1.0, 0.0, 0.0).rotated(
				#-player_ref.up_direction,
				#player_ref.move_input.angle()
			#) * horizontal_jump_force
		#)
	## Vertical Velocity
	#if player_ref.is_on_floor():
		#player_ref.linear_velocity += jump_force * player_ref.recent_floor_normal
	#elif _has_recently_touched_wall():
		#player_ref.linear_velocity += jump_force * player_ref.recent_wall_normal
	#else:
		#player_ref.linear_velocity -= player_ref.linear_velocity * player_ref.up_direction
		#player_ref.linear_velocity += jump_force * player_ref.up_direction


#func apply_jump_velocity_new(
	##jump_force: float = DEFAULT_JUMP_FORCE,
	##horizontal_jump_force: float = DEFAULT_HORIZONTAL_JUMP_FORCE,
#) -> void:
	## Give horizontal boost when jumping (this also allows for b-hopping).
	#if not player_ref.move_input.is_zero_approx():
		#player_ref.apply_central_force(
			#Vector3(1.0, 0.0, 0.0).rotated(
				#-player_ref.up_direction,
				#player_ref.move_input.angle()
			#) * DEFAULT_HORIZONTAL_JUMP_FORCE * player_ref.get_distance_from_horizontal()
		#)
	## Vertical Velocity
	#if player_ref.is_on_floor():
		#player_ref.linear_velocity += jump_force * player_ref.recent_floor_normal
	#elif _has_recently_touched_wall():
		#player_ref.linear_velocity += jump_force * player_ref.recent_wall_normal
	#else:
		#player_ref.linear_velocity -= player_ref.linear_velocity * player_ref.up_direction
		#player_ref.linear_velocity += jump_force * player_ref.up_direction


func apply_wall_jump_velocity() -> void:
	player_ref.linear_velocity -= player_ref.linear_velocity * player_ref.up_direction
	player_ref.linear_velocity -= player_ref.linear_velocity * -player_ref.recent_wall_normal
	var up_cross: Vector3 = player_ref.recent_wall_normal.cross(player_ref.up_direction).normalized()
	var direction: Vector3 = player_ref.up_direction.rotated(up_cross, -PI * 0.2)
	player_ref.linear_velocity += DEFAULT_WALL_JUMP_FORCE * direction
	can_short_hop = false


#func apply_bounce_jump_velocity() -> void:
	#apply_jump_velocity(
		#DEFAULT_BOUNCE_JUMP_FORCE,
		#DEFAULT_HORIZONTAL_BOUNCE_JUMP_FORCE
	#)


#func apply_jump_or_wall_jump_velocity() -> void:
	## Wall jump
	#if _is_wall_jump_ok():
		#apply_wall_jump_velocity()
	## Normal jump
	#else:
		#apply_jump_velocity()
#
#
#func apply_wall_jump_or_bounce_jump_velocity() -> void:
	#if _is_wall_jump_ok():
		#apply_wall_jump_velocity()
	#else:
		#apply_bounce_jump_velocity()


func jump(
	jump_force: float = DEFAULT_JUMP_FORCE,
	horizontal_jump_force: float = DEFAULT_HORIZONTAL_JUMP_FORCE,
) -> void:
	if not can_jump:
		return
	can_short_hop = true
	recently_jumped_timer_ref.start()
	short_hop_timer_ref.start()
	jump_buffer_timer_ref.stop()
	# Setting holding_jump_to_jump to false here prevents the Player from infinitely
	# bouncing when holding the jump button.
	holding_jump_to_jump = false
	
	var horizontal_launch_vector: Vector3 = (
		Vector3.ZERO
		if player_ref.move_input.is_zero_approx() else
		Vector3(
			player_ref.move_input.x,
			0.0,
			player_ref.move_input.y
		) * horizontal_jump_force
	)
	
	#Vector3Debug.display_vector(
		#horizontal_launch_vector,
		#player_ref.global_position,
		#1.0 / DEFAULT_HORIZONTAL_JUMP_FORCE,
		#1.0,
		#RA.world_ref
	#)
	
	var launch_direction: = Vector3.ZERO
	# Vertical Velocity
	# Remove any down velocity.
	var moving_down: float = player_ref.up_direction.angle_to(player_ref.linear_velocity.normalized())
	var is_moving_down: bool = moving_down > PI / 2
	if is_moving_down:
		player_ref.linear_velocity -= player_ref.linear_velocity * player_ref.up_direction
	
	launch_direction = player_ref.recent_normal
	if player_ref.is_on_floor():
		launch_direction = player_ref.recent_floor_normal
	if launch_direction.is_zero_approx():
		launch_direction = player_ref.up_direction
	
	# Angle launch vector up depending on normal.
	var wall_launch_direction: Vector3 = (
		player_ref.up_direction
		if player_ref.up_direction.is_equal_approx(launch_direction) else
		launch_direction.rotated(
			player_ref.up_direction.cross(launch_direction).normalized(),
			-player_ref.up_direction.angle_to(launch_direction) / 2.0
		)
	)
	
	var wall_difference: float = player_ref.get_distance_from_horizontal(player_ref.recent_normal) / PI
	launch_direction = wall_launch_direction.slerp(launch_direction, wall_difference)
	var launch_vector: Vector3 = launch_direction * (
		lerp(
			DEFAULT_WALL_JUMP_FORCE,
			jump_force,
			wall_difference
		)
	) + horizontal_launch_vector
	player_ref.linear_velocity += launch_vector
	
	#Vector3Debug.display_vector(
		#launch_vector,
		#player_ref.global_position,
		#1.0 / DEFAULT_JUMP_FORCE,
		#1.0,
		#RA.world_ref
	#)
	
	self.can_jump = false


func _is_jump_buffered() -> bool:
	return not jump_buffer_timer_ref.is_stopped()


func _has_recently_touched_wall() -> bool:
	return not player_ref.recent_wall_touch_timer_ref.is_stopped()


func _is_wall_jump_ok() -> bool:
	return (
		_has_recently_touched_wall() and
		not player_ref.is_on_floor() and
		not _is_too_close_to_floor_for_wall_jump()
	)


func _is_too_close_to_floor_for_wall_jump() -> bool:
	return no_wall_jump_ray_cast_ref.is_colliding()


func _on_input(event: InputEvent) -> void:
	if event.is_action_pressed("player_jump"):
		pressing_jump = true
		holding_jump_to_jump = true
		jump_buffer_timer_ref.start()
		jump()
	if event.is_action_released("player_jump"):
		pressing_jump = false
		holding_jump_to_jump = false


func _on_force(_state: PhysicsDirectBodyState3D) -> void:
	if not player_ref.is_colliding:
		return
	if recently_jumped_timer_ref.is_stopped():
		self.can_jump = true
	# Hold jump buffer.
	# TODO MAKE OPTIONAL
	if holding_jump_to_jump or _is_jump_buffered():
		jump(DEFAULT_BOUNCE_JUMP_FORCE, DEFAULT_HORIZONTAL_BOUNCE_JUMP_FORCE)
		return


func _on_short_hop_timer_timeout() -> void:
	if not (
		player_ref.is_moving_up() and
		can_short_hop and
		not pressing_jump
	):
		return
	player_ref.linear_velocity -= player_ref.up_direction * player_ref.linear_velocity
	can_short_hop = false
