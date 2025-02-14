@tool # Needed so it runs in editor.
extends EditorScenePostImport


const level_materials_dir: String = "res://res/materials/level/"
const SPIN_NODES_TSCN: PackedScene = preload("res://autoload/rolln_around/level/components/spin_nodes/spin_nodes.tscn")

enum ObjectMeta {
	SPINNING_MESH,
}


# Typed Dictionary: String, Material
var material_name_lookup: Dictionary = {}
var base_scene: Node = null


func _post_import(scene: Node) -> Node:
	base_scene = scene
	GLTFExtrasImporter.merge_extras(scene)
	_generate_material_lookup()
	_iterate_call(scene, _parse_node)
	return scene


func _generate_material_lookup() -> void:
	for file_name in DirAccess.get_files_at(level_materials_dir):
		# Translate file name to blender material name.
		var blend_mat_name: String = file_name\
			.replace("." + file_name.get_extension(), "")\
			.replace("-", " ")\
			.replace("_", " - ")\
			.to_lower()
		#
		material_name_lookup[blend_mat_name] = load(level_materials_dir + file_name)


# Recursive function that is called on every node
func _iterate_call(node: Node, callable: Callable):
	if node == null:
		return
	callable.call(node)
	for child in node.get_children():
		_iterate_call(child, callable)


func _parse_node(node: Node) -> void:
	_reassign_materials(node)
	_transform_in_spinning_mesh(node)


func _get_object_meta_name(value: ObjectMeta) -> StringName:
	match value:
		ObjectMeta.SPINNING_MESH:
			return "spinning_mesh"
	return ""


#func _get_object_meta_scene(value: ObjectMeta) -> PackedScene:
	#return null


func _transform_in_spinning_mesh(node: Node) -> void:
	var spinning_mesh_name: StringName = _get_object_meta_name(ObjectMeta.SPINNING_MESH)
	if not node is MeshInstance3D or not node.has_meta(spinning_mesh_name):
		return
	node = node as MeshInstance3D
	var spin_nodes_node: SpinNodes = SPIN_NODES_TSCN.instantiate()
	node.add_child(spin_nodes_node)
	# Adjust parameters in spin_nodes_node from meta data.
	var meta: Array = node.get_meta(spinning_mesh_name)
	meta = meta as Array[float]
	if meta.size() > 0:
		spin_nodes_node.rot_speed = meta[0]
	if meta.size() >= 4:
		spin_nodes_node.rot_axis = Vector3(meta[1], meta[2], meta[3])
	# Change StaticBody3D Collision to AnimatableBody3D
	var body_node: Node = node.get_node_or_null("StaticBody3D")
	if is_instance_valid(body_node):
		var animatable_body: = AnimatableBody3D.new()
		var target_node_paths: Array[NodePath] = []
		node.add_child(animatable_body)
		for spin_node: Node3D in [node, animatable_body]:
			target_node_paths.append(spin_nodes_node.get_path_to(spin_node))
		var body_node_children: Array[Node] = body_node.get_children()
		spin_nodes_node.target_node_paths = target_node_paths
		target_node_paths.make_read_only()
		for child in body_node_children:
			child.reparent(animatable_body)
		# May implement this manually later (rather than for loop).
		#for property_data: Dictionary in body_node.get_property_list():
			#print(property_data["name"])
			#animatable_body[property_data["name"]] = body_node[property_data["name"]]
		body_node.queue_free()
		animatable_body.owner = base_scene
	#
	spin_nodes_node.owner = base_scene


func _reassign_materials(node: Node) -> void:
	if not node is MeshInstance3D:
		return
	node = node as MeshInstance3D
	for i in node.get_surface_override_material_count():
		var file_mat_name: String = node.get_active_material(i).resource_name.to_lower()
		if not material_name_lookup.has(file_mat_name):
			continue
		node.set_surface_override_material(i, material_name_lookup[file_mat_name])
