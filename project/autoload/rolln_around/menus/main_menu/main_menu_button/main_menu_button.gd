@tool
extends Button
class_name MainMenuButton

@export var real_icon: Texture2D:
	set(value):
		real_icon = value
		# Wait until ready if doesn't exist yet
		if not is_instance_valid(icon_texture_rect):
			await ready
		icon_texture_rect.texture = value

@onready var icon_texture_rect: TextureRect = $Icon
