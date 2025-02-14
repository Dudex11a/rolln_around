extends Control


func _on_link_clicked(meta: Variant) -> void:
	if meta is String:
		OS.shell_open(meta)

