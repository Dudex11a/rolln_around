extends Control
class_name Menus


var active_menu: Control = null

@onready var main_menu_ref: Control = $MainMenu
@onready var level_select_ref: LevelSelect = $LevelSelect
@onready var credits_ref: Control = $Credits
@onready var options_ref: Control = $Options
@onready var menus: Array[Control] = [
	main_menu_ref,
	level_select_ref,
	credits_ref,
	options_ref,
]


func _ready() -> void:
	RA.paused_set.connect(_on_paused_set)


func change_menu(node_name: String) -> void:
	var old_menu: Control = active_menu
	active_menu = get_node(node_name)
	if is_instance_valid(old_menu):
		if old_menu.name == node_name:
			return
		old_menu.visible = false
	if not is_instance_valid(active_menu):
		return
	active_menu.visible = true
	# What to do when menu opened
	match node_name:
		"MainMenu":
			main_menu_ref.open()
		"LevelSelect":
			level_select_ref.open()
		_:
			(active_menu.get_children()[0] as Button).grab_focus()


func _on_paused_set(value: bool) -> void:
	visible = value
	if value and is_instance_valid(RA.active_level):
		# Change menu
		change_menu("MainMenu")
