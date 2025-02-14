@tool
extends EditorPlugin
class_name GLTFExtrasImporter

var importer

func _enter_tree() -> void:
	importer = ExtrasImporter.new()
	GLTFDocument.register_gltf_document_extension(importer)


func _exit_tree() -> void:
	GLTFDocument.unregister_gltf_document_extension(importer)


class ExtrasImporter extends GLTFDocumentExtension:
	
	func _import_post(state: GLTFState, root: Node) -> Error:
		# Add metadata to materials
		var materials_json : Array = state.json.get("materials", [])
		var materials : Array[Material] = state.get_materials()
		for i in materials_json.size():
			if materials_json[i].has("extras"):
				materials[i].set_meta("extras", materials_json[i]["extras"])
		
		# Add metadata to ImporterMeshes
		var meshes_json : Array = state.json.get("meshes", [])
		var meshes : Array[GLTFMesh] = state.get_meshes()
		for i in meshes_json.size():
			if meshes_json[i].has("extras"):
				meshes[i].mesh.set_meta("extras", meshes_json[i]["extras"])
		
		# Add metadata to nodes
		var nodes_json : Array = state.json.get("nodes", [])
		for i in nodes_json.size():
			var node = state.get_scene_node(i)
			if !node:
				continue
			if nodes_json[i].has("extras"):
				# Handle special case
				if node is ImporterMeshInstance3D:
					# ImporterMeshInstance3D nodes will be converted later to either
					# MeshInstance3D or StaticBody3D and metadata will be lost
					# A sibling is created preserving the metadata. It can be later 
					# merged back in using a EditorScenePostImport script
					var metadata_node = Node.new()
					metadata_node.set_meta("extras", nodes_json[i]["extras"])
					
					# Meshes are also ImporterMeshes that will be later converted either
					# to ArrayMesh or some form of collision shape. 
					# We'll save it as another metadata item. If the mesh is reused we'll 
					# have duplicated info but at least it will always be accurate
					if node.mesh and node.mesh.has_meta("extras"):
						metadata_node.set_meta("mesh_extras", node.mesh.get_meta("extras"))
					
					# Well add it as sibling so metadata node always follows the actual metadata owner
					node.add_sibling(metadata_node)
					# Make sure owner is set otherwise it won't get serialized to disk
					metadata_node.owner = node.owner
					# Add a suffix to the generated name so it's easy to find
					metadata_node.name += "_meta"
				# In all other cases just set_meta
				else:
					node.set_meta("extras", nodes_json[i]["extras"])
		return OK


static func _set_meta_from_extras(object: Object, extras: Dictionary) -> void:
	for key: String in extras.keys():
		object.set_meta(key, extras[key])


static func merge_extras(scene: Node, verbose: bool = false) -> void:
	var verbose_output = []
	var nodes : Array[Node] = scene.find_children("*" + "_meta", "Node")
	verbose_output.append_array(["Metadata nodes:",  nodes])
	for node in nodes:
		var extras = node.get_meta("extras")
		if !extras:
			verbose_output.append("Node %s contains no 'extras' metadata" % node)
			continue
		var parent = node.get_parent()
		if !parent:
			verbose_output.append("Node %s has no parent" % node)
			continue
		var idx_original = node.get_index() - 1
		if idx_original < 0 or parent.get_child_count() <= idx_original:
			verbose_output.append("Original node index %s is out of bounds. Parent child count: %s" % [idx_original, parent.get_child_count()])
			continue
		var original = node.get_parent().get_child(idx_original)
		if original:
			verbose_output.append("Setting extras metadata for %s" % original)
			_set_meta_from_extras(original, extras)
			if node.has_meta("mesh_extras"):
				if original is MeshInstance3D and original.mesh:
					verbose_output.append("Setting extras metadata for mesh %s" % original.mesh)
					_set_meta_from_extras(original.mesh, node.get_meta("mesh_extras"))
				else:
					verbose_output.append("Metadata node %s has 'mesh_extras' but original %s has no mesh, preserving as 'mesh_extras'" % [node, original])
					_set_meta_from_extras(original, node.get_meta("mesh_extras"))
		else:
			verbose_output.append("Original node not found for %s" % node)
		node.queue_free()
	
	if verbose:
		for item in verbose_output:
			print(item)
