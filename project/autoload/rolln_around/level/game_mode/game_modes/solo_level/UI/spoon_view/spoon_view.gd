extends SubViewport

@onready var spoon = $SpoonWorld/Spoon0
@onready var spoon_mesh = $SpoonWorld/Spoon0/SpoonMesh

enum SPOON_MATERIAL {
	DEFAULT,
	COLLECTED_BEFORE,
	EMPTY
}

@onready var enum_to_id: = {
	SPOON_MATERIAL.DEFAULT : spoon_mesh.default_material,
	SPOON_MATERIAL.COLLECTED_BEFORE : spoon_mesh.collected_before_material,
	SPOON_MATERIAL.EMPTY : spoon_mesh.empty_material,
}

@export var material_to_use: SPOON_MATERIAL

func set_material() -> void:
	if material_to_use == SPOON_MATERIAL.EMPTY:
		spoon.idle_speed = 0
	else:
		spoon.idle_speed = 1
	spoon_mesh.set_material(enum_to_id[material_to_use])
