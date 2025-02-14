extends Control


@onready var buttons_container_ref: VBoxContainer = $Buttons
@onready var resume_button_ref: Button = $Buttons/Resume
@onready var restart_button_ref: Button = $Buttons/Restart
@onready var level_select_button_ref: MainMenuButton = $Buttons/LevelSelect
@onready var quit_button_ref: MainMenuButton = %Quit


func _ready() -> void:
	RA.paused_set.connect(_on_paused_set)
	if OS.has_feature("web"):
		quit_button_ref.visible = false


func open() -> void:
	if resume_button_ref.is_visible_in_tree():
		resume_button_ref.grab_focus()
		return
	level_select_button_ref.grab_focus()


func _on_paused_set(value: bool) -> void:
	var pause_in_level: bool = value and is_instance_valid(RA.active_level)
	resume_button_ref.visible = pause_in_level
	restart_button_ref.visible = pause_in_level
	if pause_in_level:
		resume_button_ref.grab_focus()


func _on_resume_pressed() -> void:
	RA.paused = false


func _on_restart_pressed() -> void:
	RA.paused = false
	RA.active_level.reset()


func _on_level_select_pressed() -> void:
	RA.menus_ref.change_menu("LevelSelect")


func _on_player_setup_pressed() -> void:
	pass # Replace with function body.


func _on_options_pressed() -> void:
	RA.menus_ref.change_menu("Options")


func _on_credits_pressed() -> void:
	RA.menus_ref.change_menu("Credits")


func _on_quit_pressed() -> void:
	get_tree().quit()
