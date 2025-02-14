@tool
extends CanvasLayer
class_name GENPHoverDisplay


@onready var highlight_box_ref: Control = $HighlightBox


func adjust_to_node(node: Control) -> void:
	highlight_box_ref.global_position = node.global_position
	highlight_box_ref.size = node.size
