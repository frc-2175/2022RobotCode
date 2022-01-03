tool
extends Spatial

onready var start: Camera = $Start
onready var end: Camera = $End
onready var tracking: Camera = Camera.new()

var playing: bool = false
var current_time: float = 0
var play_start_time: float

enum EasingFunction { Linear, EaseInOut }
export(float) var duration_seconds: float = 5
export(EasingFunction) var easing_function: int = EasingFunction.Linear

func ensure_children():
	var start: Camera = get_node_or_null(@"Start")
	if not start:
		start = Camera.new()
		start.name = "Start"
		self.add_child(start)
		start.owner = get_tree().get_edited_scene_root()
	
	var end: Camera = get_node_or_null(@"End")
	if not end:
		end = Camera.new()
		end.name = "End"
		self.add_child(end)
		end.owner = get_tree().get_edited_scene_root()

func _editor_process():
	ensure_children()
	
	$End.fov = $Start.fov

func _ready():
	tracking.fov = start.fov
	self.add_child(tracking)

func _process(delta):
	if Engine.editor_hint:
		_editor_process()
		return
	
	current_time += delta
	
	if not playing and Input.get_action_strength("input_recording_play"):
		playing = true
		play_start_time = current_time
	
	if playing:
		var t: float = get_t()
		tracking.global_transform.origin = lerp(start.global_transform.origin, end.global_transform.origin, t)
		tracking.global_transform.basis = Quat(start.global_transform.basis).slerp(end.global_transform.basis, t)
		tracking.make_current()

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
