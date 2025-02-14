extends Node

var launch_arguments: Dictionary = {}

func _ready() -> void:
	# The code is from here
	# https://docs.godotengine.org/en/stable/classes/class_os.html#class-os-method-get-cmdline-args
	for argument in OS.get_cmdline_args():
		if argument.find("=") > -1:
			var key_value = argument.split("=")
			launch_arguments[key_value[0].lstrip("--")] = key_value[1]
		else:
			# Options without an argument will be present in the dictionary,
			# with the value set to an empty string.
			launch_arguments[argument.lstrip("--")] = ""

func is_editor_play_scene(node: Node) -> bool:
	return OS.is_debug_build() and node.name == "root" and node is Window

func get_file_name(path: String) -> String:
	var split_path: PackedStringArray = path.split("/")
	var file_name: String = split_path[split_path.size() - 1]
	# Remove extention
	return file_name.split(".")[0]

func is_node_script(node: Node, script: Script) -> bool:
	var node_script: Script = node.get_script()
	while is_instance_valid(node_script):
		if script == node_script:
			return true
		node_script = node_script.get_base_script()
	return false

# This is really inneficent, in the future I want use more explicit code.
func get_children_of_type(node: Node, type: Script) -> Array:
	var children: = []
	for child in node.get_children():
		if is_node_script(child, type):
			children.append(child)
		children.append_array(get_children_of_type(child, type))
	return children

# Keep on going up in the tree until node of type it gotten
func get_parent_of_type(node: Node, type: Script) -> Node:
	# Bail out if we reached the root
	if node.name == "root":
		return null
	# Check if node is type, otherwise look to parent
	if is_instance_valid(node):
		if is_node_script(node, type):
			return node
		else:
			return get_parent_of_type(node.get_parent(), type)
	return null
