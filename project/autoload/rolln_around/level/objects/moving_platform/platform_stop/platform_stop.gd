# Place these along the moving_platform path to make the
# platform stop.
extends PathFollow3D
class_name PlatformStop

# The amount of time spent at this stop
@export var stop_time: float = 1.0
# The amount of time to take to get to this stop
@export var travel_time: float = 1.0
# The type of ease taken to this stop
@export var ease_type: Tween.EaseType = Tween.EASE_IN_OUT
# The type of transition taken to this stop
@export var trans_type: Tween.TransitionType = Tween.TRANS_SINE
