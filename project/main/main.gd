extends Node
class_name StartGameMain


var preview_level_id: String = ""
var preview_level: Level = null


func _ready() -> void:
	RA.menus_ref.change_menu("MainMenu")
	RA.backgrounds_ref.set_background(RABackgrounds.State.FULL)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and RA.can_pause():
		# Toggle pause
		RA.paused = !RA.paused
