extends Node


signal oob_player_entered(player: Player)
signal oob_body_entered(body: CollisionObject3D)
signal player_goal_start(player: Player)
signal player_goal(player: Player)
signal paused_set(value: bool)
signal level_res_queue_finished(index: int, status: ResourceLoader.ThreadLoadStatus)
#signal level_loaded(level: Level)
signal level_started(level_path: String)
signal level_ready(level: Level)
signal setup_part_2
signal setup_part_3

const PLAYER_RES: PackedScene = preload("res://autoload/rolln_around/level/objects/player/player.tscn")
const DEBUGGING_RES_PATH: String = "res://autoload/rolln_around/debugging/debugging.tscn"
const LEVELS_DIR: String = "res://autoload/rolln_around/level/autoload/rolln_around/levels"
const GAMES_MODES_DIR: String = "res://autoload/rolln_around/level/game_mode/game_modes"
const _LEVELS_LOADING_SIZE: int = 10

var active_level: Level = null
var levels_loading_index: int = 0
var levels_loading_paths: Array[String] = [
	"", "", "", "", "", 
	"", "", "", "", "", 
]
var levels_loading_progress: Array[Array] = [
	[0.0], [0.0], [0.0], [0.0], [0.0], 
	[0.0], [0.0], [0.0], [0.0], [0.0], 
]
var existing_levels: Array[Level] = []
var pause_button_blocking_ids: Array[String] = []
# TODO What is this exactally? This is such a broad term for a variable name.
var data: Dictionary = {}

var paused: bool = false:
	set(value):
		paused = value
		paused_set.emit(value)
		get_tree().paused = value

@onready var world_ref: Node3D = %World
@onready var player_ref: Player = %Player
@onready var world_camera_ref: Camera3D = %Camera
@onready var interactive_2d_ref: CanvasLayer = %Interactive2D
@onready var menus_ref: Menus = %Menus
@onready var backgrounds_ref: RABackgrounds = $Backgrounds


func _ready() -> void:
	if OS.is_debug_build() and FileAccess.file_exists(DEBUGGING_RES_PATH):
		get_viewport().add_child.call_deferred(load(DEBUGGING_RES_PATH).instantiate())
	level_res_queue_finished.connect(_on_level_res_queue_finished)
	self.paused = true
	pause_button_blocking_ids.append("no_level_loaded")
	# Disable Player as a level will re-enable the Player.
	player_ref.disabled = true
	# For some reason I cannot run various pieces of code immediatly or waiting on ready signals.
	# I use this Callable to slopily handle the weird.
	(func():
		await get_tree().process_frame
		await get_tree().process_frame
		setup_part_2.emit()
		await get_tree().process_frame
		setup_part_3.emit()
	).call_deferred()


func make_level_path(level_id: String) -> String:
	return "%s/%s/%s.tscn" % [RA.LEVELS_DIR, level_id, level_id]


func get_level_resource(level_path: String) -> PackedScene:
	var load_threaded_status: ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(level_path)
	if (
		ResourceLoader.has_cached(level_path) or
		load_threaded_status == ResourceLoader.THREAD_LOAD_LOADED or
		load_threaded_status == ResourceLoader.THREAD_LOAD_IN_PROGRESS
	):
		var res: PackedScene = ResourceLoader.load_threaded_get(level_path)
		assert(
			is_instance_valid(res),
			"No resource found for \"%s\" in ResourceLoader." % level_path
		)
		# If is loaded or loading.
		return res
	else:
		# If isn't loaded and isn't loading.
		return load(level_path)


func _set_next_levels_loading_index() -> Error:
	for index_offset in range(_LEVELS_LOADING_SIZE):
		var i: int = (levels_loading_index + index_offset) % _LEVELS_LOADING_SIZE
		if (
			# Empty
			(
				levels_loading_paths[i] == "" and
				levels_loading_progress[i][0] == 0.0
			) or 
			# Has finished loading
			levels_loading_progress[i][0] == 1.0
		):
			levels_loading_index = i
			return OK
	return FAILED


func start_loading_level_resource(level_path: String) -> void:
	# Add level to queue
	if _set_next_levels_loading_index() == FAILED:
		print("Failed to load level resource %s. Too many resources in queue." % level_path)
		return
	var this_level_loading_index: int = levels_loading_index
	levels_loading_paths[this_level_loading_index] = level_path
	levels_loading_progress[this_level_loading_index] = [0.0]
	# Start loading level
	ResourceLoader.load_threaded_request(level_path, "PackedScene")
	process_level_loading_status(this_level_loading_index)


func get_loading_status_of_level(level_path: String, progress: Array) -> ResourceLoader.ThreadLoadStatus:
	var status: ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(level_path, progress)
	return status


func process_level_loading_status(i: int) -> void:
	var load_status: ResourceLoader.ThreadLoadStatus = ResourceLoader.THREAD_LOAD_IN_PROGRESS
	while load_status != ResourceLoader.THREAD_LOAD_LOADED:
		# Check load status
		load_status = get_loading_status_of_level(
			levels_loading_paths[i],
			levels_loading_progress[i],
		)
		# Wait and refresh
		await get_tree().process_frame
	level_res_queue_finished.emit(i, load_status)


func _on_level_res_queue_finished(i: int, load_status: ResourceLoader.ThreadLoadStatus) -> void:
	var level_path: String = levels_loading_paths[i]
	match load_status:
		ResourceLoader.THREAD_LOAD_LOADED:
			pass
			#level_loaded.emit(ResourceLoader.load_threaded_get(level_path))
		_:
			var error_topic: String = ""
			match load_status:
				ResourceLoader.THREAD_LOAD_FAILED:
					error_topic = "THREAD_LOAD_FAILED"
				ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
					error_topic = "THREAD_LOAD_INVALID_RESOURCE"
				_:
					error_topic = str(load_status)
			push_error("Failed to load path \"%s\" with error \"%s\"" % [
				level_path,
				error_topic
			])
	levels_loading_progress[i] = [1.0]


func get_level(level_path: String) -> Level:
	for level: Level in existing_levels:
		if level.scene_file_path == level_path:
			var level_parent: Node = level.get_parent()
			if is_instance_valid(level_parent):
				level_parent.remove_child(level)
			return level
	return get_level_resource(level_path).instantiate()


func start_level(level_path: String) -> void:
	if is_instance_valid(active_level):
		if active_level.scene_file_path == level_path:
			self.paused = false
			active_level.reset()
			return
		active_level.end()
	pause_button_blocking_ids.erase("no_level_loaded")
	active_level = get_level(level_path)
	world_ref.add_child(active_level)
	# Incase a camera in active_level has current set to true, set world_camera_ref to current.
	world_camera_ref.current = true
	active_level.start()
	self.paused = false
	level_started.emit(level_path)


func unload_level() -> void:
	if not is_instance_valid(active_level):
		return
	active_level.end()
	active_level.queue_free()
	active_level = null


func can_pause() -> bool:
	return pause_button_blocking_ids.size() == 0
