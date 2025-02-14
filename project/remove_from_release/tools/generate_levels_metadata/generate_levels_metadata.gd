extends Node

@export_file("*.json") var export_file: String

func _ready() -> void:
	# If scene is played from editor individually
	if G.is_editor_play_scene(get_parent()):
		run()

func run() -> void:
	# Create a dictionary to store level data
	var levels_metadata: = {}
	# Set up a for each level file
	var dir: DirAccess = DirAccess.open(RA.LEVELS_DIR)
	var levels_folder: PackedStringArray = dir.get_directories()
	for file_name in levels_folder:
		var path: String = "%s/%s/%s.tscn" % [RA.LEVELS_DIR, file_name, file_name]
		# Load level
		var level: Level = load(path).instantiate()
		add_child(level)
		# Save data to level_metadata
		var level_metadata: = {
			"name" : level.level_name,
			"index" : level.level_index,
			"catagory" : level.level_catagory_id
		}
		# Unload level
		level.queue_free()
		# Add data
		levels_metadata[file_name] = level_metadata
	# Save levels_metadata to file
	var file: FileAccess = FileAccess.open(export_file, FileAccess.WRITE)
	file.store_string(JSON.stringify(levels_metadata, "\t"))
	file = null
	print("Level metadata has been generated!")
