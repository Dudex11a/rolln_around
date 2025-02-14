extends Node
class_name GameMode


@onready var level_ref: Level = get_parent()


func _ready() -> void:
	level_ref.game_mode_ref = self


func start() -> void:
	pass


func end() -> void:
	pass


func reset() -> void:
	pass


func setup() -> void:
	pass


func delete() -> void:
	end()
	queue_free()


func get_game_mode_save() -> GameModeSave:
	return GameModeSave.new()


func load_game_mode_save(_game_mode_save: GameModeSave) -> void:
	pass
