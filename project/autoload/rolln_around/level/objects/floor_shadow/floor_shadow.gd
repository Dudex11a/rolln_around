extends Node3D


const VERTICAL_OFFSET: float = 0.06

@onready var shadow_raycast: RayCast3D = $ShadowRayCast
@onready var shadow_sprite: Sprite3D = $ShadowSprite


func _physics_process(_delta: float) -> void:
	var collision_y_pos = get_collision_y_pos()
	var is_colliding: bool = collision_y_pos is float
	# Show shadow if colliding
	shadow_sprite.visible = is_colliding
	# Adjust shadow decal to shadow raycast pos
	if is_colliding:
		shadow_sprite.global_transform.origin.y = collision_y_pos + VERTICAL_OFFSET

func get_collision_y_pos():
	if shadow_raycast.is_colliding():
		return shadow_raycast.get_collision_point().y
	return null

# TEMP, Generate rays later instead of just using one
func generate_rays() -> void:
	pass
