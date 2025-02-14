extends Control

@onready var default_size: Vector2 = size

# How much to scale the ui within this node
@export var scale_amount: float = 1.0:
	set(value):
		# Have the minimum value be 0.001 to avoid negative numbers
		# and dividing by zero.
		scale_amount = max(value, 0.001)
		scale = Vector2(value, value)
		# Adjust UI size and position acording to scale and default size
		size = default_size / scale_amount
		_on_resized()
# If the node will use a global ui value stored in the root
@export var use_global_ui_scale: bool = true

const global_scale_id: String = "global_ui_scale"

func _ready() -> void:
	# Connect game resized to method
	get_viewport().size_changed.connect(_on_resized)
	# Set global ui scale if exists and this node is set to use it
	if use_global_ui_scale and get_tree().has_meta(global_scale_id):
		self.scale_amount = get_tree().get_meta(global_scale_id)

# ----- Group

func set_ui_scale(value: float) -> void:
	# Do stuff if this node uses the global ui scale
	if use_global_ui_scale:
		self.scale_amount = value
		# Set global_ui_scale
		get_tree().set_meta(global_scale_id, scale_amount)

# ----- Signals

func _on_resized() -> void:
	var viewport_size: Vector2 = get_viewport().size
	# Adjust width with scale in mind
	size = viewport_size / scale_amount
