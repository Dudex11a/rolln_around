@tool
extends Control
class_name SettingsItem


signal file_dialog_button_pressed
signal delete_button_pressed

@onready var file_line_edit: LineEdit = %FileLineEdit


func set_file_path(path: String) -> void:
	file_line_edit.text = path


# TODO Add Error Handling


func _on_file_dialog_button_pressed() -> void:
	file_dialog_button_pressed.emit()


func _on_delete_button_pressed() -> void:
	delete_button_pressed.emit()


func _on_file_line_edit_text_changed(new_text: String) -> void:
	# TODO Error Handling
	pass # Replace with function body.
