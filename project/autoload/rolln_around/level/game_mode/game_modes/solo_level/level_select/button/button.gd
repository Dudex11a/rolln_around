extends LevelButton
class_name SoloLevelButton


const STATS_SPOON_SLOT_RES: PackedScene = preload("res://autoload/rolln_around/level/game_mode/game_modes/solo_level/level_select/status_spoon_slot/status_spoon_slot.tscn")

@export var amount_of_spoons: int = 0

var spoon_container_ref: HBoxContainer = null

@onready var level_completed_icon_ref: TextureRect = %LevelCompletedIcon
@onready var spoon_completed_ref: Control = %SpoonCompleted
@onready var spoon_completed_icon_ref: TextureRect = %SpoonCompletedIcon



func _ready() -> void:
	await RA.setup_part_2
	status_ref = level_select_ref.solo_level_status_ref
	level_select_ref.level_button_lookup[level_path] = self
	spoon_container_ref = status_ref.spoon_container_ref


func _on_hovered() -> void:
	super._on_hovered()
	for spoon_slot: StatusSpoonSlot in spoon_container_ref.get_children():
		spoon_slot.queue_free()
	if not SM.game_save.level_saves.has(level_path):
		return
	var solo_level_save: SoloLevelSave = SM.game_save.level_saves[level_path].game_mode_save
	for i in amount_of_spoons:
		var spoon_slot: StatusSpoonSlot = STATS_SPOON_SLOT_RES.instantiate()
		spoon_container_ref.add_child(spoon_slot)
		if solo_level_save.spoons_collected_before.has(i + 1):
			spoon_slot.set_texture(SpoonSlot.ICON_TEXTURE)
		else:
			spoon_slot.set_texture(SpoonSlot.ICON_OUTLINE_TEXTURE)
	level_select_ref.active_status_ref = status_ref


func level_save_set(level_save: LevelSave) -> void:
	var solo_level_save: SoloLevelSave = level_save.game_mode_save
	level_completed_icon_ref.visible = solo_level_save.level_completed
	spoon_completed_ref.visible = amount_of_spoons != 0
	spoon_completed_icon_ref.visible = amount_of_spoons == solo_level_save.spoons_collected_before.size()
