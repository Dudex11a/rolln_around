extends CanvasLayer
class_name RABackgrounds


enum State {
	NONE,
	FULL,
	PARTIAL,
}

var _background: State = State.NONE:
	set = set_background

@onready var full_background_ref: CanvasLayer = $FullBackground
@onready var partial_background_ref: CanvasLayer = $PartialBackground


func set_background(value: State) -> void:
	var old_background: State = _background
	if old_background == value:
		return
	_background = value
	var old_background_node: CanvasLayer = _get_background_node(old_background)
	if is_instance_valid(old_background_node):
		old_background_node.visible = false
	var background_node: CanvasLayer = _get_background_node()
	if is_instance_valid(background_node):
		background_node.visible = true


func _get_background_node(value: State = _background) -> CanvasLayer:
	match value:
		State.FULL:
			return full_background_ref
		State.PARTIAL:
			return partial_background_ref
	return null
