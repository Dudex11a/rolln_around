@tool
extends SubViewportContainer

var tracked_cam: WeakRef
@onready var tracking_cam = $Viewport/Camera
@onready var aspect_ratio_container: AspectRatioContainer = $".."


func _ready() -> void:
	var ratio: float = (
		float(ProjectSettings.get("display/window/size/viewport_width")) /
		float(ProjectSettings.get("display/window/size/viewport_height"))
	)
	aspect_ratio_container.ratio = ratio


func _process(_delta: float) -> void:
	if tracked_cam and tracked_cam.get_ref():
		var cam = tracked_cam.get_ref()
		tracking_cam.global_transform = cam.global_transform
		tracking_cam.fov = cam.fov
		tracking_cam.keep_aspect = cam.keep_aspect
		tracking_cam.cull_mask = cam.cull_mask
		tracking_cam.environment = cam.environment
		tracking_cam.h_offset = cam.h_offset
		tracking_cam.v_offset = cam.v_offset
		tracking_cam.doppler_tracking = cam.doppler_tracking
		tracking_cam.projection = cam.projection
		tracking_cam.fov = cam.fov
		tracking_cam.size = cam.size
		tracking_cam.frustum_offset = cam.frustum_offset
		tracking_cam.near = cam.near
		tracking_cam.far = cam.far
