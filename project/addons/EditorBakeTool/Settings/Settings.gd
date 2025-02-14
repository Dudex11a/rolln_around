@tool
extends Window
class_name EBTSettings


const SETTINGS_ITEM_RES: PackedScene = preload("res://addons/EditorBakeTool/Settings/SettingsItem/SettingsItem.tscn")

var file_dialog_active_item: SettingsItem = null

@onready var items_container_ref: VBoxContainer = %ItemsContainer
@onready var file_dialog_ref: FileDialog = $FileDialog


func _on_close_requested() -> void:
	hide()


func _on_add_button_pressed() -> void:
	var item: SettingsItem = SETTINGS_ITEM_RES.instantiate()
	items_container_ref.add_child(item)
	item.file_dialog_button_pressed.connect(_on_file_dialog_pressed.bind(item))
	item.delete_button_pressed.connect(_on_delete_pressed.bind(item))


func _on_file_dialog_pressed(item: SettingsItem) -> void:
	file_dialog_active_item = item
	file_dialog_ref.show()


func _on_delete_pressed(item: SettingsItem) -> void:
	item.file_dialog_button_pressed.disconnect(_on_file_dialog_pressed)
	item.delete_button_pressed.disconnect(_on_delete_pressed)
	item.queue_free()


func _close_file_dialog() -> void:
	file_dialog_ref.hide()


func _on_file_dialog_file_selected(path: String) -> void:
	file_dialog_active_item.set_file_path(path)
	file_dialog_ref.hide()
	# TODO Validate if it's a EditorBakeTool.
