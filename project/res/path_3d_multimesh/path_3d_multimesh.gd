# Create meshes along the path's curve
@tool
extends Path3D
class_name Path3DMultiMesh

@onready var dotted_mesh_inst: MultiMeshInstance3D = $DottedMeshInst
@onready var curve_points_mesh_inst: MultiMeshInstance3D = $CurvePointsMeshInst
@onready var dotted_multimesh: MultiMesh = null:
	set(value):
		dotted_multimesh = value
		dotted_mesh_inst.multimesh = dotted_multimesh
@onready var curve_points_multimesh: MultiMesh = null:
	set(value):
		curve_points_multimesh = value
		curve_points_mesh_inst.multimesh = curve_points_multimesh
@export var default_dotted_multimesh: MultiMesh
@export var default_curve_points_multimesh: MultiMesh

@export var bake: bool = false:
	set(value):
		print("Bake Start")
		create_mesh()
		print("Bake Finished")
# Params
# The ratio for how many dots there should be
# length unit : this variable
@export var dotted_line_length_to_dot_ratio: float = 2.0

func _ready() -> void:
	# End if not editor
	if not Engine.is_editor_hint():
		return
	# Make sure mesh_inst are editable so I can some the mesh_inst's values
	# within this tool
	var parent: Node = get_parent()
	if not parent.is_editable_instance(self):
		parent.set_editable_instance(self, true)
	# Make curve unique (I keep screwing this up when making new paths)
	# This ends now.
	curve = curve.duplicate()

func create_mesh() -> void:
	# Create new meshes over dotten_multimesh
	dotted_multimesh = default_dotted_multimesh.duplicate()
	curve_points_multimesh = default_curve_points_multimesh.duplicate()
	# Create new mesh
	create_dotted_line()

func create_dotted_line() -> void:
	# Calculate how many dots are needed inbetween stops
	var path_length: float = curve.get_baked_length()
	var point_count: int = curve.point_count
	# Set instance count of dotted lines and points
	dotted_multimesh.instance_count = ceil(path_length) / dotted_line_length_to_dot_ratio
	curve_points_multimesh.instance_count = point_count
	# Create big dot for each point and create dots between current and next point
	var dot_i: int = 0
	for point_i in point_count:
		var point_vec: Vector3 = curve.get_point_position(point_i)
		var point_trans: = Transform3D(Basis(), point_vec)
		curve_points_multimesh.set_instance_transform(point_i, point_trans)
		# End if last point, there is no need for "dots between" since
		# there is only a start point (start = point_i, end = point_i + 1)
		if point_i == point_count - 1:
			continue
		# Create dots inbetween this and last point
		var next_point: int = point_i + 1
		# Get amount of length and dots between
		var length_between: float = get_length_between_points_of_curve(point_i, next_point)
		var dots_between: int = round(length_between) / dotted_line_length_to_dot_ratio
		# Get the point offset for later
		var point_offset: float = curve.get_closest_offset(curve.get_point_position(point_i))
		for point_dot_i in range(dots_between):
			# Calculate and place dots at points between
			var dot_offset: float = calculate_dot_offset(point_dot_i, dots_between, length_between, point_offset)
			# Get pos
			var dot_pos: Vector3 = curve.sample_baked(dot_offset)
			# Calculate rotation to next point
			#var dot_rot: = Vector3.ZERO
			# Calculate next pos
			var next_pos_offset: float = calculate_dot_offset(point_dot_i + 1, dots_between, length_between, point_offset)
			var next_pos: Vector3 = curve.sample_baked(next_pos_offset)
			# Get rotation data to look at the next point
			var rot_direction: Vector3 = dot_pos.direction_to(next_pos).normalized()
			var look_up: = Vector3(0, 0.99, 0.01)
			var dot_trans: = Transform3D(Basis.looking_at(rot_direction, look_up), dot_pos)
			# Set dot pos (FINALLY)
			dotted_multimesh.set_instance_transform(dot_i, dot_trans)
			# Increment overall dot_i
			dot_i += 1

func calculate_dot_offset(dot_i: int, dots_between: int, length_between: float, point_offset: float) -> float:
	return ((float(dot_i + 1.0) / float(dots_between + 1.0)) * length_between) + point_offset

# I use this to get the length between two points on a Curve3D.
# I think this concept (not this code) should be something natively in Godot,
# I should sugest it
func get_length_between_points_of_curve(a: int, b: int) -> float:
	var between_curve: = Curve3D.new()
	# Add points to curve
	for i in [a, b]:
		var point_pos: Vector3 = curve.get_point_position(i)
		var point_in: Vector3 = curve.get_point_in(i)
		var point_out: Vector3 = curve.get_point_out(i)
		between_curve.add_point(point_pos, point_in, point_out)
	# Bake and return length
	return between_curve.get_baked_length()
