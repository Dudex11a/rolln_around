extends Node
class_name SpinNodes


@export var rot_axis: Vector3 = Vector3.UP
@export var rot_speed: float = 1.0
@export var target_node_paths: Array[NodePath] = []

var target_nodes: Array[Node3D] = []
var start_quats: Array[Quaternion] = []

@onready var get_game_mode: GetGameMode = $GetGameMode


func _ready() -> void:
	$GetGameMode.got_game_mode.connect(_on_got_game_mode)
	for target_node_path in target_node_paths:
		var node: Node3D = get_node(target_node_path)
		target_nodes.append(node)
		start_quats.append(node.quaternion)


func _physics_process(delta: float) -> void:
	for node in target_nodes:
		node.rotate(rot_axis, delta * rot_speed)


func _on_got_game_mode(game_mode: GameMode) -> void:
	game_mode.level_ref.setup_finished.connect(_on_game_mode_setup_finished)


func _on_game_mode_setup_finished() -> void:
	for i in target_nodes.size():
		target_nodes[i].quaternion = start_quats[i]
