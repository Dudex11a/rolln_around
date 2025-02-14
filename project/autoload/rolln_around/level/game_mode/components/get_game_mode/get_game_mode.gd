extends Node
class_name GetGameMode


signal got_game_mode(game_mode: GameMode)

var game_mode_ref: GameMode = null

@onready var get_level_ref: GetLevel = $GetLevel


func _ready() -> void:
	get_level_ref.got_level.connect(_on_got_level)


func _on_got_level(level: Level) -> void:
	game_mode_ref = level.game_mode_ref
	got_game_mode.emit(game_mode_ref)
