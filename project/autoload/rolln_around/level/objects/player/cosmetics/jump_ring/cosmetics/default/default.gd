extends JumpRingCosmetic


@onready var jump_ring_mesh_ref: MeshInstance3D = %JumpRingMesh


func _process(delta: float) -> void:
	jump_ring_mesh_ref.rotate_y(delta)


func surface_material_override(index: int, material: Material) -> void:
	jump_ring_mesh_ref.set_surface_override_material(index, material)
