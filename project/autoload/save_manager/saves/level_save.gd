extends RefCounted
class_name LevelSave


enum Keys {
	GAME_MODE_SAVE = 0,
	LEVEL_SAVE = 1,
	LEVEL_PATH = 2,
}

var game_mode_save: GameModeSave = null
var level_path: String = "YOU_SHOULDNT_SEE_THIS"


func to_dictionary() -> Dictionary:
	return {
		Keys.GAME_MODE_SAVE: game_mode_save.to_dictionary(),
		Keys.LEVEL_SAVE: get_script().resource_path,
		Keys.LEVEL_PATH: level_path,
	}


func from_dictionary(dictionary: Dictionary) -> void:
	# game_mode_save
	var game_mode_dictionary: Dictionary = dictionary[str(Keys.GAME_MODE_SAVE)]
	game_mode_save = _get_game_mode_save(
		game_mode_dictionary[str(GameModeSave.Keys.GAME_MODE_SAVE)]
	)
	game_mode_save.from_dictionary(game_mode_dictionary)
	# level_path
	level_path = dictionary[str(Keys.LEVEL_PATH)]
	# level_save is parsed in game_save.gd.


func _get_game_mode_save(id: String) -> GameModeSave:
	match id:
		SoloLevelSave.ID:
			return SoloLevelSave.new()
		_:
			return load(id).new()
