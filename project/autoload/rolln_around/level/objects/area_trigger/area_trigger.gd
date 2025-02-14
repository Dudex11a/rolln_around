extends Node3D
class_name AreaTrigger

@export var camera_transition_speed: float = 0.6

var start_quat: = Quaternion.IDENTITY
var start_pos: = Vector3.ZERO
var start_fov: float = 0
var enabled: bool = false:
	set(value):
		enabled = value
		area_ref.set_deferred("monitoring", enabled)
var level_ref: Level = null
var last_active_area: AreaTrigger = null

@onready var camera_ref: Camera3D = $Camera
@onready var area_ref: Area3D = $Area3D


func _ready() -> void:
	RA.player_goal_start.connect(_on_player_goal_start)
	area_ref.body_shape_entered.connect(_on_area_3d_body_shape_entered)


func transition() -> void:
	if level_ref.active_area == self or not enabled:
		return
	last_active_area = level_ref.active_area
	level_ref.active_area = self
	# Save velocity
	var a_v: Vector3 = RA.player_ref.angular_velocity
	var l_v: Vector3 = RA.player_ref.linear_velocity
	RA.player_ref.freeze = true
	RA.pause_button_blocking_ids.append("area_trigger")
	get_tree().paused = true
	await translate_camera()
	RA.pause_button_blocking_ids.erase("area_trigger")
	RA.player_ref.freeze = false
	get_tree().paused = false
	# Translate or don't translate velocity
	await get_tree().physics_frame
	await get_tree().physics_frame
	RA.player_ref.angular_velocity = a_v
	RA.player_ref.linear_velocity = l_v


# Translate level_ref camera_ref to another camera_ref
func translate_camera() -> void:
	# Set start values
	start_quat = RA.world_camera_ref.quaternion
	start_pos = RA.world_camera_ref.global_position
	start_fov = RA.world_camera_ref.fov
	# Translate over timer
	var true_camera_transition_speed: float = camera_transition_speed
	if is_instance_valid(last_active_area):
		true_camera_transition_speed = \
			(camera_transition_speed + last_active_area.camera_transition_speed) / 2.0
	var timer: SceneTreeTimer = get_tree().create_timer(true_camera_transition_speed)
	while timer.time_left > 0:
		# A value from 0 -> 1 indicating how far the timer has progressed towards completion
		var timer_completion: float = abs(timer.time_left / true_camera_transition_speed - 1)
		# Translate values based on timer_completion
		RA.world_camera_ref.quaternion = start_quat.slerp(camera_ref.quaternion, timer_completion)
		RA.world_camera_ref.global_position = start_pos.slerp(camera_ref.global_position, timer_completion)
		RA.world_camera_ref.fov = lerp(start_fov, camera_ref.fov, timer_completion)
		# Wait
		await get_tree().process_frame
	snap()


func snap() -> void:
	level_ref.active_area = self
	RA.world_camera_ref.quaternion = camera_ref.quaternion
	RA.world_camera_ref.global_position = camera_ref.global_position
	RA.world_camera_ref.fov = camera_ref.fov


func _on_area_3d_body_shape_entered(_body_rid: RID, body: Node3D, _body_shape_index: int, _local_shape_index: int) -> void:
	if body is Player:
		transition()


func _on_player_goal_start(_player: Player) -> void:
	self.enabled = false


func _on_get_game_mode_got_game_mode(game_mode: GameMode) -> void:
	if game_mode is GameModeSoloLevel:
		level_ref = game_mode.level_ref
		game_mode.player_spawned.connect(_on_player_spawned)


func _on_player_spawned(_player: Player) -> void:
	self.enabled = true
