extends Node


const save_path: String = "user://save_game.json"

var game_save: GameSave = null


func _ready() -> void:
	game_save = GameSave.new()
	game_save.level_save_set.connect(_on_level_save_set)
	await RA.setup_part_3
	game_save.load_file()


func _on_level_save_set(level_save: LevelSave) -> void:
	if not RA.menus_ref.level_select_ref.level_button_lookup.has(level_save.level_path):
		push_warning("Level %s from GameSave doesn't exist" % level_save.level_path)
		return
	var level_button: LevelButton = \
		RA.menus_ref.level_select_ref.level_button_lookup[level_save.level_path]
	level_button.level_save_set(level_save)


# OLD FILE BELOW

#@onready var json: = JSON.new()

#var game_save: GameSave = GameSave.new()

#class GameSave:
	#var levels: Dictionary = {}
	#var colors: Array[Color] = []
	#var options: Dictionary = {}
	#
	#const save_vars: Array[String] = ["levels", "options"]
#
#
#func _ready() -> void:
	#load_save()
#
#
#func obj2dic(obj: Object) -> Dictionary:
	#var dic: = {}
	## The object must have save_variables defined
	## The save_vars will be used to get values from the object
	#if "save_vars" in obj:
		#for var_name in obj.save_vars:
			#dic[var_name] = obj[var_name]
	#return dic
#
#func set_obj_vars(obj: Object, dic: Dictionary) -> void:
	#if "save_vars" in obj:
		## If the object has save vars it will use those
		#for var_name in obj.save_vars:
			## Convert if necessary
			#match typeof(obj[var_name]):
				#TYPE_PACKED_BYTE_ARRAY:
					#if dic[var_name] is String:
						#obj[var_name] = PackedByteArray(
							#str_to_var(dic[var_name])
						#)
					#else:
						#obj[var_name] = PackedByteArray(dic[var_name])
				#_:
					## Save to object
					#obj[var_name] = dic[var_name]
	#else:
		#for var_name in dic.keys():
			#obj[var_name] = dic[var_name]
#
#func save_object(obj, path: String) -> void:
	#var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	#var dic: Dictionary = obj2dic(obj)
	#var content: String = JSON.stringify(dic, "\t")
	#file.store_string(content)
	#file = null
#
#func load_file(path: String) -> Dictionary:
	#var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	#if is_instance_valid(file):
		#json.parse(file.get_as_text())
		#file = null
		#var data = json.get_data()
		#if data == null:
			#return {}
		#return data
	#return {"error" = ERR_FILE_CANT_OPEN}
#
#func save_game(save: GameSave = game_save, path: String = save_path):
	#save_object(save, path)
#
#func load_save(path: String = save_path) -> void:
	## Create new GameSave
	#game_save = GameSave.new()
	#if FileAccess.file_exists(path):
		## Load save
		#var file_dic: Dictionary = load_file(path)
		#if "error" in file_dic:
			#var error: int = file_dic.error
			#match file_dic.error:
				#OK:
					## Load file into game_save
					#set_obj_vars(game_save, file_dic)
				#ERR_FILE_CANT_OPEN:
					#push_error("Can't open file. Can't load save.")
				#_:
					#push_error("Error loading ", error)
	#else:
		## If file not found, make a file
		#save_game(game_save, path)
