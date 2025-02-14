extends RefCounted
class_name GameSave


signal file_saved
signal file_loaded
signal level_save_set(level_save: LevelSave)


enum Keys {
	SAVE_VERSION = 0,
	LEVEL_SAVES = 1,
}

const SAVE_VERSION: int = 0

# Typed Dictionary: [String (LevelID), LevelSave]
var level_saves: Dictionary = {}


func load_file(path: String = SM.save_path) -> void:
	if FileAccess.file_exists(path):
		var file: = FileAccess.open(path, FileAccess.READ)
		from_dictionary(JSON.parse_string(file.get_as_text()))
	else:
		save_file(path)


func save_file(path: String = SM.save_path) -> void:
	var file: = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(to_dictionary(), "\t"))
	file.close()


func to_dictionary() -> Dictionary:
	# TODO Cosmetics
	# TODO Player Colors
	var dictionary: Dictionary = {
		Keys.SAVE_VERSION: SAVE_VERSION,
		Keys.LEVEL_SAVES: [],
	}
	# LEVEL_SAVES
	for level_id: String in level_saves.keys():
		var level_save: LevelSave = level_saves[level_id]
		var level_save_dictionary: Dictionary = level_save.to_dictionary()
		dictionary[Keys.LEVEL_SAVES].append(level_save_dictionary)
	return dictionary


func from_dictionary(value: Dictionary) -> void:
	# SAVE_VERSION
	var dictionary: Dictionary = _update(value)
	# LEVEL_SAVES
	for level_dictionary: Dictionary in dictionary[str(Keys.LEVEL_SAVES)]:
		var level_save_id: String = level_dictionary[str(LevelSave.Keys.LEVEL_SAVE)]
		var level_save: LevelSave = load(level_save_id).new()
		level_save.from_dictionary(level_dictionary)
		set_level_save(level_save)
	# TODO Cosmetics
	# TODO Player Colors


func set_level_save(level_save: LevelSave) -> void:
	level_saves[level_save.level_path] = level_save
	level_save_set.emit(level_save)


## Adjust the save file the current SAVE_VERSION is old. 
func _update(dictionary: Dictionary) -> Dictionary:
	return dictionary
