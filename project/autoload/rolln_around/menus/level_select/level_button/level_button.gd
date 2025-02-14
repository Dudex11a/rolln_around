extends Button
class_name LevelButton


@export_file("*.tscn") var level_path: String = ""
@export var level_name: String = ""

var status_ref: GameModeStatus = null

@onready var level_select_ref: LevelSelect = get_parent().get_parent().get_parent().get_parent().get_parent().get_parent()
@onready var menus_ref: Menus = level_select_ref.get_parent()


func _on_hovered() -> void:
	menus_ref.level_select_ref.start_loading_preview_level(level_path)
	level_select_ref.level_name_ref.text = level_name


func _on_pressed() -> void:
	RA.start_level(level_path)


func level_save_set(_level_save: LevelSave) -> void:
	return
