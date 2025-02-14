extends Node3D
class_name Level


signal activated
signal setup_finished

## If the level is currently being played
var active: bool = false:
	set(value):
		active = value
		if active:
			activated.emit()
var game_mode_ref: GameMode = null

@onready var active_area: AreaTrigger = null
@onready var spawn_ref: Spawn = $Spawn
@onready var start_area_trigger_ref: Node3D = $StartAreaTrigger


func _ready() -> void:
	ready.connect(_on_level_ready)


func start() -> void:
	setup()
	game_mode_ref.start()
	self.active = true


func end() -> void:
	RA.player_ref.disabled = true
	game_mode_ref.end()


func reset() -> void:
	setup()
	game_mode_ref.reset()


func setup() -> void:
	RA.player_ref.disabled = false
	game_mode_ref.setup()
	setup_finished.emit()


func get_id() -> String:
	return G.get_file_name(scene_file_path)


func get_level_save_script() -> GDScript:
	return LevelSave


func get_level_save() -> LevelSave:
	var level_save: LevelSave = get_level_save_script().new()
	level_save.game_mode_save = game_mode_ref.get_game_mode_save()
	return level_save


func save_game_save() -> void:
	var level_save: LevelSave = get_level_save()
	level_save.level_path = scene_file_path
	SM.game_save.set_level_save(level_save)
	# Save file
	SM.game_save.save_file()


func load_game_save() -> void:
	if not SM.game_save.level_saves.has(scene_file_path):
		return
	var level_save: LevelSave = SM.game_save.level_saves[scene_file_path]
	game_mode_ref.load_game_mode_save(level_save.game_mode_save)


func _on_level_ready() -> void:
	RA.level_ready.emit(self)
