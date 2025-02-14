extends Control
class_name StatusSpoonSlot


@onready var texture_rect_ref: TextureRect = %TextureRect


func set_texture(texture: Texture) -> void:
	texture_rect_ref.texture = texture
