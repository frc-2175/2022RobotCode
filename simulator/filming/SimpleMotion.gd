extends RigidBody

export(NodePath) var start_node
export(NodePath) var end_node

var playing: bool = false
var current_time: float = 0
var play_start_time: float

enum EasingFunction { Linear, EaseInOut }
export(float) var duration_seconds: float = 5
export(EasingFunction) var easing_function: int = EasingFunction.Linear

onready var start = get_node(start_node)
onready var end = get_node(end_node)

func _process(delta):
	current_time += delta
	
	if not playing:
		self.global_transform.origin = lerp(self.global_transform.origin, start.global_transform.origin, 0.01)
	
	if not playing and Input.get_action_strength("input_recording_play"):
		playing = true
		play_start_time = current_time
	
	if playing:
		var t: float = get_t()
		self.global_transform.origin = lerp(start.global_transform.origin, end.global_transform.origin, t)

func get_t() -> float:
	var t: float = clamp((current_time - play_start_time) / duration_seconds, 0, 1)
	match easing_function:
		EasingFunction.Linear:
			return t
		EasingFunction.EaseInOut:
			if t < 0.5:
				return 4 * t * t * t
			else:
				return 1 - pow(-2 * t + 2, 3) / 2
		_:
			return t
