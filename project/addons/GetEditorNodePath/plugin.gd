@tool
extends EditorPlugin
class_name InspectEditorNodesPlugin


const HOVER_DISPLAY_RES: PackedScene = preload("res://addons/GetEditorNodePath/HoverDisplay.tscn")
var hover_display_ref: GENPHoverDisplay = null
var hover_behaviors: Array[HoverBehavior] = []
var active_node: Control = null


func _enter_tree() -> void:
	hover_display_ref = HOVER_DISPLAY_RES.instantiate()
	var base_control: Control = EditorInterface.get_base_control()
	base_control.add_child(hover_display_ref)
	hover_display_ref.owner = base_control
	hover_display_ref.visible = false
	_for_each_node(_create_hover_behavior)


func _exit_tree() -> void:
	hover_behaviors.clear()
	hover_display_ref.queue_free()
	hover_display_ref = null


func _get_plugin_name() -> String:
	return "Get Editor Node Path"


func _input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	event = (event as InputEventMouseButton)
	if not (
		event.pressed and
		# Right Click
		event.button_index == 2
	):
		return
	var path: String = str(
		EditorInterface.get_base_control().get_path_to(active_node)
	)
	print(_get_plugin_name())
	print("Selected node path saved to clipboard:")
	print(path)
	DisplayServer.clipboard_set(path)


func set_active_node(node: Control) -> void:
	active_node = node
	hover_display_ref.adjust_to_node(node)


func _for_each_node(
	callable: Callable,
	node: Node = EditorInterface.get_base_control()
) -> void:
	callable.call(node)
	for child: Node in node.get_children():
		if is_instance_valid(child):
			_for_each_node(callable, child)


func _create_hover_behavior(node: Node) -> void:
	if node is Control:
		HoverBehavior.new(node, self)


class HoverBehavior:
	
	var node: Control = null
	var hovered: bool = false
	var plugin: InspectEditorNodesPlugin = null
	
	
	func _init(n_node: Node, n_plugin: InspectEditorNodesPlugin) -> void:
		node = n_node
		node.mouse_entered.connect(_on_mouse_entered)
		node.mouse_exited.connect(_on_mouse_exited)
		plugin = n_plugin
		plugin.tree_exiting.connect(_on_tree_exited)
		plugin.hover_behaviors.append(self)
	
	
	func _on_mouse_entered() -> void:
		hovered = true
		plugin.hover_display_ref.visible = true
		plugin.set_active_node(node)
	
	
	func _on_mouse_exited() -> void:
		hovered = false
	
	
	func _on_tree_exited() -> void:
		node.mouse_entered.disconnect(_on_mouse_entered)
		node.mouse_exited.disconnect(_on_mouse_exited)
		plugin.tree_exiting.disconnect(_on_tree_exited)
