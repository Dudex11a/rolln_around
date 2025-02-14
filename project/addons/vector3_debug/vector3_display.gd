extends Node3D
class_name Vector3DebugDisplay


@onready var destroy_timer_ref: Timer = $DestroyTimer
@onready var strength_label_ref: Label3D = $StrengthLabel
@onready var direction_mesh_ref: MeshInstance3D = $DirectionMesh
@onready var x_mesh_ref: MeshInstance3D = $XMesh
@onready var y_mesh_ref: MeshInstance3D = $YMesh
@onready var z_mesh_ref: MeshInstance3D = $ZMesh


func set_vector(vector: Vector3, vec_scale: float = 1.0) -> void:
	strength_label_ref.text = "\n%s\n%s" % [vector.length(), vector]
	# Material
	direction_mesh_ref.get_surface_override_material(0).set(
		"shader_parameter/direction",
		vector
	)
	# Set mesh scale to correspond to mesh_vector.length().
	var mesh_ref_vector_material_info: Dictionary = {
		direction_mesh_ref: vector,
		x_mesh_ref: vector * Vector3(1.0, 0.0, 0.0),
		y_mesh_ref: vector * Vector3(0.0, 1.0, 0.0),
		z_mesh_ref: vector * Vector3(0.0, 0.0, 1.0),
	}
	for mesh_ref: MeshInstance3D in mesh_ref_vector_material_info.keys():
		var mesh_vector: Vector3 = mesh_ref_vector_material_info[mesh_ref]
		# Size and rotation
		mesh_ref.scale.y = mesh_vector.length() * vec_scale
	# Set direction_mesh_ref rotation.
	var normal_vector: Vector3 = vector.normalized()
	var other_vec: = Vector3.UP
	if not (
		normal_vector.is_zero_approx() or 
		normal_vector.is_equal_approx(other_vec)
	):
		direction_mesh_ref.quaternion = Quaternion(
			normal_vector.cross(other_vec).normalized(),
			-normal_vector.angle_to(other_vec)
		)


func _on_destroy_timer_timeout() -> void:
	queue_free()
