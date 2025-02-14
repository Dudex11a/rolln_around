extends RefCounted
class_name GameModeSave


enum Keys {
	GAME_MODE_SAVE = 0,
}


func to_dictionary() -> Dictionary:
	return {
		# Default
		#Keys.GAME_MODE_SAVE: get_script().resource_path,
	}


func from_dictionary(_value: Dictionary) -> void:
	pass
