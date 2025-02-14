extends Control
class_name LevelSelect


var preview_level: Level = null
var preview_level_path: String = ""
var active_status_ref: GameModeStatus = null: set = _set_active_status
# Typed Dictionary: [String (LevelID), LevelButton]
var level_button_lookup: Dictionary

@onready var level_preview_viewport_ref: SubViewport = %LevelPreviewViewport
@onready var level_name_ref: Label = %LevelName
@onready var first_level_button_ref: LevelButton = %TestLevelButton
@onready var solo_level_status_ref: SoloLevelStatus = $RightSide/GameModeStatus/SoloLevelStatus
@onready var level_preview_ratio_container_ref: AspectRatioContainer = %LevelPreviewRatioContainer


func _ready() -> void:
	RA.level_res_queue_finished.connect(_on_level_res_queue_finished)
	get_viewport().size_changed.connect(_on_size_changed)


func open() -> void:
	first_level_button_ref.grab_focus()


func remove_preview_level() -> void:
	if is_instance_valid(preview_level):
		RA.existing_levels.erase(preview_level)
		preview_level.queue_free()
		preview_level = null


func load_level_res_into_preview(level_res: PackedScene) -> void:
	preview_level = level_res.instantiate()
	level_preview_viewport_ref.add_child(preview_level)
	RA.existing_levels.append(preview_level)


func start_loading_preview_level(level_path: String) -> void:
	#if level_path == preview_level_path:
		#return
	remove_preview_level()
	if is_instance_valid(RA.active_level):
		if RA.active_level.scene_file_path == level_path:
			return
	preview_level_path = level_path
	if ResourceLoader.has_cached(level_path):
		load_level_res_into_preview(ResourceLoader.load_threaded_get(level_path))
	else:
		RA.start_loading_level_resource(level_path)


func _get_button_from_level_id(_id: String) -> LevelButton:
	return null


func _set_active_status(value: GameModeStatus) -> void:
	var old_status: GameModeStatus = active_status_ref
	active_status_ref = value
	if active_status_ref == old_status:
		return
	if is_instance_valid(old_status):
		old_status.visible = false
	if is_instance_valid(active_status_ref):
		active_status_ref.visible = true


func _on_level_res_queue_finished(
	level_loading_index: int,
	status: ResourceLoader.ThreadLoadStatus
) -> void:
	if status != ResourceLoader.THREAD_LOAD_LOADED:
		print("status not loaded")
		return
	var level_path: String = RA.levels_loading_paths[level_loading_index]
	if level_path != preview_level_path:
		return
	var res: PackedScene = ResourceLoader.load_threaded_get(level_path)
	if is_instance_valid(res):
		load_level_res_into_preview(res)
	else:
		push_warning("Failed to get level res \"%s\". This is likely an invalid path or double loading the same resource (?)" % level_path)


func get_status_by_button(button: LevelButton) -> GameModeStatus:
	if button is SoloLevelButton:
		return solo_level_status_ref
	return null


func _on_size_changed() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	level_preview_ratio_container_ref.ratio = float(viewport_size.x) / float(viewport_size.y)


# I might use this in a tool script later to generate UI.
#func generate_ui() -> void:
	#var levels_metadata: Dictionary = RA.data.levels_metadata
	## Order levels in catagories and in level order
	## Level catagories : [level_ids in order]
	#var ordered_levels_in_catgories: Dictionary = {"misc" : []}
	#for level_id in levels_metadata.keys():
		#var level_metadata: Dictionary = levels_metadata[level_id]
		#var level_index: int = level_metadata.index
		#var catagory_id: String = "misc"
		## Create catagory in ordered_levels_in_catgories and set the catagory_id
		## to the defined catagory
		#if "catagory" in level_metadata.keys():
			#catagory_id = level_metadata.catagory
			## Create empty Array in catagory
			#if not catagory_id in ordered_levels_in_catgories:
				#ordered_levels_in_catgories[level_metadata.catagory] = []
		## Add into catagory
		#var catagory: Array = ordered_levels_in_catgories[catagory_id]
		#catagory.append({"id": level_id, "index": level_index})
		## Sort catagory
		#catagory.sort_custom(func (a, b): return a.index < b.index)
	## Get catagories order
	#var catagories_metadata: Dictionary = RA.data.catagories
	#var ordered_catagories: = []
	## Add all catagories and indexes to a array
	#for catagory_id in catagories_metadata.keys():
		#var catagory_metadata: Dictionary = catagories_metadata[catagory_id]
		##var catagory_index: int = catagory_metadata.index
		## Add catagories data
		#var ordered_catagory_data: Dictionary = {"id": catagory_id}
		#ordered_catagory_data.merge(catagory_metadata)
		#ordered_catagories.append(ordered_catagory_data)
	## Order catagories and ids
	#ordered_catagories.sort_custom(func (a, b): return a.index < b.index)
	## Create level catagories
	#var level_catagories: Dictionary = {}
	#for catagory_data in ordered_catagories:
		#var catagory_id: String = catagory_data.id
		## Create and add catagory
		#var level_catagory: LevelCatagory = level_catagory_res.instantiate()
		#vbox_container.add_child(level_catagory)
		#level_catagory.propagate(catagories_metadata[catagory_id])
		#level_catagories[catagory_id] = level_catagory
		## Hide if not visible OPTION
		#if "visible" in catagory_data and not OS.is_debug_build():
			#level_catagory.visible = catagory_data.visible
	## Create buttons for each level id in their catagory
	#var level_row: Control
	#var hbox_container: HBoxContainer
	## Loops through catagories
	#for catagory_id in ordered_levels_in_catgories.keys():
		## Stop catagory if doesn't exist
		#if not catagory_id in level_catagories:
			#printerr("No catagory found: ", catagory_id)
			#continue
		#var level_catagory: LevelCatagory = level_catagories[catagory_id]
		#var levels_data: Array = ordered_levels_in_catgories[catagory_id]
		## Stop catagory if there is no levels data
		## This is here to prevent some code at the end primarily
		#if levels_data.size() <= 0:
			#continue
		## Loop through levels
		#for loop_index in range(levels_data.size()):
			## Create HBoxContainer for every row
			#if loop_index % levels_per_row == 0:
				#level_row = level_row_res.instantiate()
				#hbox_container = level_row.get_node("HBoxContainer")
				#level_catagory.add_child(level_row)
				## Move HBox down by level_catagory height
				#level_row.position.y = level_catagory.size.y
				## Increase catagory height based on HBox size
				#level_catagory.custom_minimum_size.y += level_row.size.y
			#var level_id: String = levels_data[loop_index].id
			#var level_metadata: Dictionary = levels_metadata[level_id]
			## Create button
			#var button: = level_button_res.instantiate()
			#button.propagate(level_id, level_metadata)
			#hbox_container.add_child(button)
		## If last HBoxContainer doesn't have enough levels_per_row
		## add empty spaces so the level_buttons don't stretch too much
		#var child_count: int = hbox_container.get_child_count()
		#if child_count < levels_per_row:
			#var amount_of_space_to_add: int = levels_per_row - child_count
			## Add spacers
			#for index in range(amount_of_space_to_add):
				#var spacer: = Control.new()
				#hbox_container.add_child(spacer)
				#spacer.custom_minimum_size.y = 80
				#spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
