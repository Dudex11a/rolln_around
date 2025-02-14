extends Node


func _ready() -> void:
	var v1 = Vector2(1.0, 1.0)
	var v2 = Vector2(0.5, 0.25)
	print(v1.project(v2))
