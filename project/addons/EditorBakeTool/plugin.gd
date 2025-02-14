@tool
extends EditorPlugin


enum ItemIDIndex {
	SEPARATOR = 0,
	PLUGIN_SETTINGS = 1,
}

const SETTINGS_RES: PackedScene = preload("res://addons/EditorBakeTool/Settings/Settings.tscn")

var project_menu_item_ids: PackedInt32Array = []
var project_menu: Window = null
var settings_ref: EBTSettings = null


func _enter_tree() -> void:
	settings_ref = SETTINGS_RES.instantiate()
	settings_ref.visible = false
	EditorInterface.get_base_control().add_child(settings_ref)
	project_menu = get_node("../@Panel@13/@VBoxContainer@14/@EditorTitleBar@15/@MenuBar@111/Project")
	project_menu.id_pressed.connect(_on_id_pressed)
	# Item ID 0 = Separator
	_add_project_menu_item(project_menu.add_separator, "")
	# Item ID 1 = Plugin Settings
	_add_project_menu_item(
		project_menu.add_item,
		_get_plugin_name() + " Settings..."
	)


func _exit_tree() -> void:
	settings_ref.queue_free()
	settings_ref = null
	project_menu.id_pressed.disconnect(_on_id_pressed)
	for id: int in project_menu_item_ids:
		project_menu.remove_item(project_menu.get_item_index(id))


func _get_plugin_name() -> String:
	return "Editor Bake Tool"


func _add_project_menu_item(add_item_call: Callable, label: String) -> void:
	var next_item_id: int = project_menu.item_count
	add_item_call.call(label, next_item_id)
	project_menu_item_ids.append(next_item_id)


func _on_id_pressed(id: int) -> void:
	if id != project_menu_item_ids[ItemIDIndex.PLUGIN_SETTINGS]:
		return
	settings_ref.show()
