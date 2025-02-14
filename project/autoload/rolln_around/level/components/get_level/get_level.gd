extends Node
class_name GetLevel


signal got_level(level: Level)

var level_ref: Level = null


func _ready() -> void:
	RA.level_ready.connect(_on_level_ready)


func _on_level_ready(value: Level) -> void:
	if is_instance_valid(level_ref):
		return
	got_level.emit(value)
