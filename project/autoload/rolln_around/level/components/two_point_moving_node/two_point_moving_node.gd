extends Node


@export var move_amount: = Vector3(0, 0, 0)
@export var move_duration: float = 1.0
@export var transition_type: Tween.TransitionType = Tween.TRANS_SINE

var tween: Tween = null

@onready var get_game_mode: GetGameMode = %GetGameMode
@onready var parent_ref: Node3D = get_parent()
@onready var start_pos: Vector3 = parent_ref.global_position


func _ready() -> void:
	get_game_mode.got_game_mode.connect(_on_got_game_mode)


func _on_got_game_mode(game_mode: GameMode) -> void:
	game_mode.level_ref.setup_finished.connect(_on_game_mode_setup_finished)


func _on_game_mode_setup_finished() -> void:
	parent_ref.global_position = start_pos
	if is_instance_valid(tween):
		tween.kill()
		tween = null
		# The wait is here so the global_position change is registered.
		await get_tree().physics_frame
		await get_tree().physics_frame
	tween = create_tween()\
		.set_loops()\
		.set_trans(Tween.TRANS_SINE)
	tween.tween_property(
		parent_ref,
		"global_position",
		start_pos + move_amount,
		move_duration / 2.0
	)
	tween.tween_property(
		parent_ref,
		"global_position",
		start_pos,
		move_duration / 2.0
	)
	
