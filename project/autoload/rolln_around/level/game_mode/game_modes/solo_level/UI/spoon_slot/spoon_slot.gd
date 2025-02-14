extends Control
class_name SpoonSlot


const ICON_TEXTURE: CompressedTexture2D = preload("res://autoload/rolln_around/level/game_mode/game_modes/solo_level/UI/spoon_slot/res/icon.png")
const ICON_COLLECTED_BEFORE_TEXTURE: CompressedTexture2D = preload("res://autoload/rolln_around/level/game_mode/game_modes/solo_level/UI/spoon_slot/res/icon_collected_before.png")
const ICON_OUTLINE_TEXTURE: CompressedTexture2D = preload("res://autoload/rolln_around/level/game_mode/game_modes/solo_level/UI/spoon_slot/res/icon_outline.png")

var spoon_node: Spoon = null:
	set(value):
		spoon_node = value
		value.player_collected.connect(_on_player_collected)
		spoon_node.level_ref.setup_finished.connect(_on_game_mode_setup)

var level_ref: Level = null


@onready var texture_rect_ref: TextureRect = $TextureRect


func _on_player_collected(_player: Player) -> void:
	if spoon_node.has_been_collected_before:
		texture_rect_ref.texture = ICON_COLLECTED_BEFORE_TEXTURE
	else:
		texture_rect_ref.texture = ICON_TEXTURE


func _on_game_mode_setup() -> void:
	texture_rect_ref.texture = ICON_OUTLINE_TEXTURE
