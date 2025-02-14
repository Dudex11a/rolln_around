extends Area3D
class_name OutOfBounds

func _on_out_of_bounds_body_shape_entered(_body_rid: RID, body: Node3D, _body_shape_index: int, _local_shape_index: int) -> void:
	if body is Player:
		RA.oob_player_entered.emit(body)
	else:
		RA.oob_body_entered.emit(body)
