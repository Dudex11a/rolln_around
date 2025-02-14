extends GameMode
class_name GameModeSoloLevel


signal player_spawned(player: Player)

const SPOON_SLOT_RES: PackedScene = preload("res://autoload/rolln_around/level/game_mode/game_modes/solo_level/UI/spoon_slot/spoon_slot.tscn")
const ID: String = "SOLO_LEVEL"

# Typed Dictionary: [int, Spoon]
var spoons: Dictionary = {}

# If the level is completed currently,
# not if it's been completed before
var level_completed: bool = false:
	set(value):
		var old_level_completed: bool = level_completed
		if old_level_completed == value:
			return
		level_completed = value
		if level_completed:
			_on_level_completed()

@onready var results_ref: Control = $Results
@onready var reset_button_ref: MainMenuButton = %Reset
@onready var spoon_indicators_ref: Control = $SpoonIndicators
@onready var spoons_collected_container: HBoxContainer = $SpoonIndicators/SpoonsCollected


func _ready() -> void:
	super()
	RA.oob_player_entered.connect(_on_oob_player_entered)
	RA.player_goal.connect(_when_player_goal)
	RA.paused_set.connect(_on_paused_set)
	# TODO Bake in these initial values on debug and export.
	# I could also make separate scene files maybe as a solution?
	# That could be better...
	results_ref.visible = false
	# Wait for after all Spoons are assigned.
	await ready
	await get_tree().process_frame
	level_ref.load_game_save()


func start() -> void:
	RA.menus_ref.visible = false
	RA.backgrounds_ref.set_background(RABackgrounds.State.NONE)
	spoon_indicators_ref.visible = true
	move_results_to_2d()
	super()


func end() -> void:
	RA.pause_button_blocking_ids.erase("solo_level_finished")
	RA.backgrounds_ref.set_background(RABackgrounds.State.FULL)
	spoon_indicators_ref.visible = false
	move_results_from_2d()
	super()


func reset() -> void:
	# Make sure level exists since game_mode doesn't get deleted with
	# the level, I might want to change this later. 
	if not is_instance_valid(level_ref):
		return
	if not level_ref.active:
		return
	RA.pause_button_blocking_ids.erase("solo_level_finished")
	self.level_completed = false


func setup() -> void:
	level_ref.start_area_trigger_ref.snap()
	spawn_player(RA.player_ref)
	hide_results()
	level_ref.load_game_save()
	super()


func get_game_mode_save() -> GameModeSave:
	var game_mode_save: SoloLevelSave = SoloLevelSave.new()
	var spoons_collected_before: Array[int] = []
	for spoon: Spoon in spoons.values():
		if spoon.has_been_collected_before or spoon.is_collected:
			spoons_collected_before.append(spoon.get_id())
	game_mode_save.spoons_collected_before = spoons_collected_before
	game_mode_save.level_completed = level_completed
	return game_mode_save


func load_game_mode_save(solo_level_save: GameModeSave) -> void:
	solo_level_save = (solo_level_save as SoloLevelSave)
	for index: int in spoons.keys():
		var spoon: Spoon = spoons[index]
		spoon.has_been_collected_before = index in solo_level_save.spoons_collected_before


func assign_spoon(value: Spoon) -> void:
	spoons[value.get_id()] = value
	# TODO These slots can be baked in, I need to make a tool for this.
	var spoon_slot: SpoonSlot = SPOON_SLOT_RES.instantiate()
	spoons_collected_container.add_child(spoon_slot)
	spoon_slot.spoon_node = value


## Move the results_ref node from this scene to the interactive_2d_ref
## in RA. I'm having issues with input in different Control nodes theoretically
## because they don't stem from the same 2D parent, they have different base "Node"s.
func move_results_to_2d() -> void:
	results_ref.reparent(RA.interactive_2d_ref)


func move_results_from_2d() -> void:
	results_ref.reparent(self)


func show_results() -> void:
	RA.paused = true
	RA.menus_ref.visible = false
	reset_button_ref.grab_focus()
	results_ref.visible = true
	# TODO Move results into InteractiveUI
	# TODO
	# Move Spoon Indicators with animation to center of screen
	# or back to corner when results are visible or not
	#var spoon_slots: Array[SpoonSlot] = get_spoon_slots()


func hide_results() -> void:
	results_ref.visible = false


func spawn_player(player: Player) -> void:
	player.linear_velocity = Vector3.ZERO
	player.angular_velocity = Vector3.ZERO
	player.rotation = Vector3.ZERO
	# This is here because the player.global_position won't set without it.
	# I don't know what's causing the issue.
	await get_tree().process_frame
	player.global_position = level_ref.spawn_ref.get_spawn_point()
	# Wait for physics to catch up with the global_position move.
	await get_tree().physics_frame
	player_spawned.emit(player)


func get_spoon_slots() -> Array:
	return spoons_collected_container.get_children()


func _when_player_goal(_player: Player) -> void:
	if level_ref.active:
		self.level_completed = true


func _set_level_button_visiblity(value: bool) -> void:
	RA.menus_ref.main_menu_ref.resume_button_ref.visible = value
	RA.menus_ref.main_menu_ref.restart_button_ref.visible = value


func _exit_results_screen() -> void:
	hide_results()
	_set_level_button_visiblity(false)
	RA.menus_ref.visible = true
	RA.unload_level()


# Respawn player when out of bounds
func _on_oob_player_entered(player: Player) -> void:
	if not level_ref.active:
		return
	## Spawn player
	#spawn_player(player)
	level_ref.reset()


func _on_level_completed() -> void:
	RA.pause_button_blocking_ids.append("solo_level_finished")
	RA.menus_ref.main_menu_ref.resume_button_ref.visible = false
	level_ref.save_game_save()
	show_results()


func _on_next_level_pressed() -> void:
	RA.start_level(level_ref.next_level_path)


func _on_reset_pressed() -> void:
	level_ref.reset()
	RA.paused = false


func _on_main_menu_button_pressed() -> void:
	_exit_results_screen()
	RA.menus_ref.change_menu("MainMenu")
	# For some reason change_menu fails to grab_focus to the correct Node so I that here.
	RA.menus_ref.main_menu_ref.level_select_button_ref.grab_focus()


func _on_level_select_pressed() -> void:
	_exit_results_screen()
	RA.menus_ref.change_menu("LevelSelect")


func _on_paused_set(value: bool) -> void:
	if value:
		RA.backgrounds_ref.set_background(RABackgrounds.State.PARTIAL)
	else:
		RA.backgrounds_ref.set_background(RABackgrounds.State.NONE)
