extends Node3D
class_name Spoon


signal player_collected(player: Player)

const COLLECTED_BEFORE_MATERIAL: Material = preload("res://autoload/rolln_around/level/objects/spoon/res/collected_before.material")
const DEFAULT_MATERIAL: Material = preload("res://autoload/rolln_around/level/objects/spoon/res/default.material")
const EMPTY_MATERIAL: Material = preload("res://autoload/rolln_around/level/objects/spoon/res/empty.material")

enum IdleMode {
	NONE,
	SPIN,
	JIVE
}

enum State {
	INIT,
	NOT_COLLECTED_EVER_BEFORE,
	NOT_COLLECTED_HAS_BEEN_BEFORE,
	COLLECTED,
}

@export var idle_speed: float = 1.0
@export var idle_mode: IdleMode = IdleMode.SPIN

var level_ref: Level = null

var is_collected: bool = false:
	set(value):
		#var old_is_collected: bool = is_collected
		#if value != old_is_collected:
			#return
		is_collected = value
		if is_collected:
			anim_player_ref.play("Collect")
		else:
			anim_player_ref.play("RESET")
			_update_material()
			_play_idle_anim()

var has_been_collected_before: bool = false:
	set(value):
		var old_has_been_collected_before: bool = has_been_collected_before
		has_been_collected_before = value
		var is_has_been_collected_before_different: bool = \
			value != old_has_been_collected_before
		if not is_has_been_collected_before_different:
			return
		_update_material()

@onready var spoon_mesh_ref: MeshInstance3D = %SpoonMesh
@onready var anim_player_ref: AnimationPlayer = %AnimationPlayer


func _ready() -> void:
	RA.level_ready.connect(_on_level_ready)
	# I need to initialize the idle anim here as the method in which 
	# _play_idle_anim is called won't doesn't start _play_idle_anim since
	# _play_idle_anim only works when the old_enabled value is different
	# from enabled.
	_update_material()
	_play_idle_anim()


func get_id() -> int:
	return int(str(name))


func _reset_rotation() -> void:
	anim_player_ref.play("RESET")
	spoon_mesh_ref.rotation.y = 0


func _update_material() -> void:
	if get_tree().paused:
		await RA.paused_set
	if has_been_collected_before:
		spoon_mesh_ref.set_surface_override_material(0, COLLECTED_BEFORE_MATERIAL)
	else:
		spoon_mesh_ref.set_surface_override_material(0, DEFAULT_MATERIAL)


func _player_collect(player: Player) -> void:
	if is_collected == true:
		return
	self.is_collected = true
	player_collected.emit(player)


func _play_idle_anim() -> void:
	# Play animation
	while not is_collected:
		var delta: float = get_process_delta_time()
		match idle_mode:
			IdleMode.NONE:
				break
			IdleMode.SPIN:
				spoon_mesh_ref.rotation.y += idle_speed * delta
			IdleMode.JIVE:
				spoon_mesh_ref.rotation.y = (sin(Time.get_ticks_usec() * delta * idle_speed / 4500) / 2.0)
		await get_tree().process_frame


func _on_area_3d_body_shape_entered(_body_rid: RID, body: Node3D, _body_shape_index: int, _local_shape_index: int) -> void:
	if body is Player:
		_player_collect(body)


func _on_level_ready(value: Level) -> void:
	if is_instance_valid(level_ref):
		return
	level_ref = value
	if level_ref.game_mode_ref is GameModeSoloLevel:
		level_ref.game_mode_ref.assign_spoon(self)
		level_ref.setup_finished.connect(_on_game_mode_setup)


func _on_game_mode_setup() -> void:
	self.is_collected = false
