# Use this node to move nodes that'll follow along
# the Path3D. Put the nodes you want to move in the container node.
# Add PlatformStops to make the object stop along the path.
extends Node3D

@onready var path_3d_multimesh: Path3DMultiMesh = $Path3DMultiMesh
@onready var path_curve: Curve3D = path_3d_multimesh.curve
@onready var follow: PathFollow3D = path_3d_multimesh.get_node("Follow")
@onready var container: AnimatableBody3D = $Container
@onready var platform_stops: Array[PlatformStop] = get_ordered_platform_stops()

## If the follow should start at the first point after the last
## as apposed to going in reverse after the last has been reached.
## After traveling to the last stop it'll use the first stop's
## data (pos, ease_type, etc...) to travel to.
@export var continuous: bool = false
## If the container should rotate with the path
@export var rotate_with_path: bool = false
# The offset the follow is at or should be set in the moving platform
var follow_offset: float = 0.0:
	set(value):
		follow_offset = value
		# Set value in follow
		follow.progress_ratio = follow_offset
		# Wait and set container position based follow pos
		container.position = follow.position
		if rotate_with_path:
			container.rotation = follow.rotation

var tween: Tween = null

func _ready() -> void:
	# Start plat
	start()

func start() -> void:
	if is_instance_valid(tween):
		tween.kill()
	# Create new tween
	tween = get_tree().create_tween().set_loops()
	tween.bind_node(self)
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	create_tweeners_for_stops(platform_stops)
	if continuous:
		# Immediatly go back to the start stop's offset
		var last_stop: PlatformStop = platform_stops[platform_stops.size() - 1]
		var tweener: PropertyTweener = tween.tween_property(self, "follow_offset", 0.0, 0.0)
		tweener.set_delay(last_stop.stop_time)
	else:
		# Make tweeners for the trip back if not continuous
		var reversed_platform_stops: Array[PlatformStop] = platform_stops.duplicate()
		# Flip the stops and then remove the first (we're already there)
		reversed_platform_stops.reverse()
		create_tweeners_for_stops(reversed_platform_stops)

# Loop through stops and create tweeners for each
func create_tweeners_for_stops(stops: Array[PlatformStop]) -> void:
	for stop_i in range(stops.size()):
		var next_stop_i: int = stop_i + 1
		# End if there is no next_stop then end
		if stop_i >= stops.size() - 1:
			continue
		var current_stop: PlatformStop = stops[stop_i]
		var next_stop: PlatformStop = stops[next_stop_i]
		create_stop_tweener(tween, current_stop, next_stop)

#func create_stop_tweener(tween: Tween, next_stop: PlatformStop, last_stop: PlatformStop = null) -> Tweener:
#	# Make tweener
#	var tweener: PropertyTweener = tween.tween_property(self, "follow_offset", next_stop.progress_ratio, next_stop.travel_time)
#	# Take ease and trans from last_stop if there is one
#	if is_instance_valid(last_stop):
#		tweener.set_ease(last_stop.ease_type).set_trans(last_stop.trans_type)
#	else:
#		tweener.set_ease(next_stop.ease_type).set_trans(next_stop.trans_type)
#	# After tween, then delay
#	tweener.set_delay(next_stop.stop_time)
#	printt(next_stop.travel_time, next_stop.stop_time)
#	return tweener

func create_stop_tweener(n_tween: Tween, current_stop: PlatformStop, next_stop: PlatformStop) -> Tweener:
	# Make tweener
	var tweener: PropertyTweener = n_tween.tween_property(self, "follow_offset", next_stop.progress_ratio, current_stop.travel_time)
	# Take ease and trans from last_stop if there is one
	tweener.set_ease(current_stop.ease_type).set_trans(current_stop.trans_type)
	# After tween, then delay
	tweener.set_delay(current_stop.stop_time)
	return tweener

func get_ordered_platform_stops() -> Array[PlatformStop]:
	var stops: Array[PlatformStop] = []
	# Get all stops from path
	for child in path_3d_multimesh.get_children():
		if child is PlatformStop:
			stops.append(child)
	# Order based on offset
	stops.sort_custom(func (a: PlatformStop, b: PlatformStop):
		return a.progress_ratio < b.progress_ratio)
	return stops

# ----- Group


func _on_get_level_got_level(level: Level) -> void:
	level.setup_finished.connect(_on_level_setup)


func _on_level_setup() -> void:
	# Reset follow offset and restart moving
	self.follow_offset = 0.0
	start()
