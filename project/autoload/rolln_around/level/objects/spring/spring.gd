extends Node3D


const TOP_Y_DEPRESS: float = 0.1
const TOP_Y_EXTEND: float = 0.9
const LAUNCH_CURVE: Curve = preload("res://autoload/rolln_around/level/objects/spring/res/launch_curve.res")
const STRENGTH_MODIFIER: float = 15.0
const ANIM_EXTEND_MODIFIER: float = 0.5

# Strength influences launch speed and how far the spring stretches
@export_range(0.0, 10.0) var strength: float = 1.0

var level_ref: Level = null

var spring_launched: bool = false

var spring_extend: float = 0.0:
	set(value):
		spring_extend = value
		# Set top_ref position
		top_ref.position.y = lerp(TOP_Y_DEPRESS, TOP_Y_EXTEND, value)
		shadow_animatable_body_ref.global_position = top_ref.global_position
		# Set depression
		wire_mesh_ref.set("blend_shapes/Extended", value)

@onready var top_ref: Node3D = $Top
@onready var wire_mesh_ref: MeshInstance3D = $Wire/Wire
@onready var detection_area_ref: Area3D = %DetectionArea
@onready var launch_timer_ref: Timer = $LaunchTimer
@onready var shadow_animatable_body_ref: AnimatableBody3D = %ShadowAnimatableBody
@onready var extend_distance: float = strength
@onready var descend_time: float = sqrt((strength * 2) * 10) / 10
@onready var descend_loops: int = round(strength)


func _ready() -> void:
	RA.level_ready.connect(_on_level_ready)


## This was super overkill, just using an anim-player would have
## been totally fine for this kind of animation but I went nuts
## with this procedurally animated spring.
## TODO Do I even want this anymore?
#func launch_spring() -> void:
	## Don't launch if already launched
	#if spring_launched:
		#return
	## Start
	#spring_launched = true
	#var prop_name: String = "spring_extend"
	## Launch
	#var tween: Tween = get_tree().create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	#tween.bind_node(self)
	#var extend_tween: = tween.tween_property(self, prop_name, extend_distance, 0.25)
	#extend_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).from(0.0)
	## Bounce down and up with distance decreasing over time and speed incresing
	#var last_destination: float = extend_distance
	#var float_loops: = float(descend_loops)
	## Calculate the times
	#var time_values: Array[float] = []
	#var all_together: float = 0
	## Multiply the loops because we need twice the values of the loops for
	## each tween. We add one more after for the final tween.
	#var descend_loops_2: int = (descend_loops * 2) + 1
	## Get curve values
	#for i in range(descend_loops_2):
		#var value: float = descend_curve.sample(float(i + 1) / float(descend_loops))
		#time_values.append(value)
		#all_together += value
	#var factor: float = descend_time / all_together
	## Multiply values from the curve by the factor that was just created.
	## What this will do is that all the values will now add up to the descend_time
	## so I can define how fast I want the spring to descend.
	#for i in range(descend_loops_2):
		#time_values[i] *= factor
	## Create the rest of the tweens
	#for index in range(descend_loops):
		#var time_1_index: int = index * 2
		#var time_2_index: int = time_1_index + 1
		## On the first indexes have time be larger than last indexes
		## I still want it to only take as much time as the descend time
		##var time = descend_loops
		#var next_destination: float = ((abs(index - float_loops) - 1) / float_loops)
		## Bring closer to bottom
		#next_destination /= 2
		## Account for extention
		#next_destination *= extend_distance
		## Down
		#var descend_tween_1 = tween.tween_property(self, prop_name, next_destination - last_destination, time_values[time_1_index])
		#descend_tween_1.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC).as_relative()
		#last_destination = next_destination
		#next_destination = lerp(next_destination, (next_destination + extend_distance) / 2, 0.5)
		## Back up a little
		#var descend_tween_2 = tween.tween_property(self, prop_name, next_destination - last_destination, time_values[time_2_index])
		#descend_tween_2.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC).as_relative()
		#last_destination = next_destination
	## Go to 0
	#var end_tween = tween.tween_property(self, prop_name, -last_destination, time_values[time_values.size() - 1])
	#end_tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC).as_relative()
	## On end
	#await tween.finished
	#spring_launched = false
	## Launch spring again if body in detection_area_ref and the body isn't only itself
	#var overlapping_bodies: Array = detection_area_ref.get_overlapping_bodies()
	#if detection_area_ref.get_overlapping_bodies().size() <= 0:
		#return
	#if top_body_ref in overlapping_bodies and detection_area_ref.get_overlapping_bodies().size() == 1:
		#return
	#launch_spring()


func _launch_spring(body: Node3D) -> void:
	# Start
	if spring_launched:
		return
	spring_launched = true
	# Launch
	if body is RigidBody3D:
		var direction: Vector3 = Vector3.UP
		var axis: Vector3 = quaternion.get_axis()
		if not axis.is_zero_approx():
			direction = direction.rotated(
				axis,
				quaternion.get_angle(),
			)
		# Remove body velocity associated with the up direction of the Spring.
		body.linear_velocity -= body.linear_velocity * direction
		# Apply launch impulse.
		var impulse: = direction * strength * STRENGTH_MODIFIER
		body.apply_central_impulse(impulse)
		#Vector3Debug.display_vector(
			#direction,
			#RA.player_ref.global_position,
			#1.0,
			#1.0,
			#RA.world_ref,
		#)
	launch_timer_ref.start()
	while not launch_timer_ref.is_stopped() and spring_launched:
		var progress: float = abs((launch_timer_ref.time_left / launch_timer_ref.wait_time) - 1.0)
		self.spring_extend = LAUNCH_CURVE.sample(progress) * strength * ANIM_EXTEND_MODIFIER
		await get_tree().physics_frame
	# End
	_reset_spring()
	if detection_area_ref.get_overlapping_bodies().size() == 0:
		return
	_launch_spring(body)


func _reset_spring() -> void:
	spring_launched = false
	self.spring_extend = 0.0


func _on_area_3d_body_shape_entered(_body_rid: RID, body: Node3D, _body_shape_index: int, _local_shape_index: int) -> void:
	# Launch
	_launch_spring(body)


func _on_level_ready(value: Level) -> void:
	if is_instance_valid(level_ref):
		return
	level_ref = value
	_reset_spring()
	if level_ref.game_mode_ref is GameModeSoloLevel:
		level_ref.setup_finished.connect(_on_game_mode_setup)


func _on_game_mode_setup() -> void:
	launch_timer_ref.stop()
	_reset_spring()
