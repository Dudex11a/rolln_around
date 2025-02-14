extends Control

@onready var tools: Node = $Tools

# ----- Signals

func _on_glm_pressed() -> void:
	tools.get_node("GenerateLevelMetadata").run()
