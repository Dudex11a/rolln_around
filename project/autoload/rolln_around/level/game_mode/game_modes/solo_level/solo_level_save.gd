extends GameModeSave
class_name SoloLevelSave


const ID: String = "SOLO_LEVEL"

enum SoloLevelKeys {
	SPOONS_COLLECTED_BEFORE = 100,
	LEVEL_COMPLETED = 101,
	
}


var spoons_collected_before: Array[int] = []
var level_completed: bool = false


func to_dictionary() -> Dictionary:
	return {
		Keys.GAME_MODE_SAVE: ID,
		SoloLevelKeys.SPOONS_COLLECTED_BEFORE: spoons_collected_before,
		SoloLevelKeys.LEVEL_COMPLETED: level_completed,
	}


func from_dictionary(dictionary: Dictionary) -> void:
	super.from_dictionary(dictionary)
	spoons_collected_before = []
	for id in dictionary[str(SoloLevelKeys.SPOONS_COLLECTED_BEFORE)]:
		spoons_collected_before.append(int(id))
	level_completed = bool(dictionary[str(SoloLevelKeys.LEVEL_COMPLETED)])
