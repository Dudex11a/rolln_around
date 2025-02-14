extends Node
## When this scene is ran, it will export images of spoon.tscn for UI.


const export_path: String = "res://autoload/rolln_around/level/game_mode/game_modes/solo_level/UI/spoon_slot/res/"

@onready var sub_viewport_ref: SubViewport = %SubViewport
@onready var spoon_ref: Spoon = sub_viewport_ref.get_node("World/Spoon0")


func _ready() -> void:
	spoon_ref.idle_mode = Spoon.IdleMode.NONE
	# Wait for render. Apparently I wait 2 process_frames?
	# I don't know how else to get when the first frame is rendered.
	await get_tree().process_frame
	await get_tree().process_frame
	#
	_save_viewport_image("icon")
	spoon_ref.spoon_mesh.set_surface_override_material(0, Spoon.COLLECTED_BEFORE_MATERIAL)
	await get_tree().process_frame
	_save_viewport_image("icon_collected_before")
	spoon_ref.spoon_mesh.set_surface_override_material(0, Spoon.EMPTY_MATERIAL)
	await get_tree().process_frame
	_save_viewport_image("icon_outline")
	get_tree().quit()


func _save_viewport_image(file_name: String) -> void:
	var image: Image = sub_viewport_ref.get_texture().get_image()
	image.save_png(export_path + file_name + ".png")
