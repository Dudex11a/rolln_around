extends BallCosmetic


@export var colors: Array[Color] = [
	Color("f20c0c"),
	Color("f2bcaa"),
]

@onready var ball_mesh_ref: MeshInstance3D = %BallMesh


func _ready() -> void:
	update_color_materials()


func update_color_materials() -> void:
	for i in colors.size():
		set_color(i, colors[i])


func set_color(index: int, color: Color) -> void:
	var mat: StandardMaterial3D = ball_mesh_ref.get_surface_override_material(index)
	mat.set("albedo_color", color)


func get_colors() -> Array[Color]:
	return colors
