extends Object

class_name RobotInput

# This class contains centralized code for robot user input when the WPILib
# simulator is inactive. Use this instead of using Godot's Input class directly
# to make sure recordings play back correctly.

var frame = null

var frame_actions = [
	"robot_forward",
	"robot_backward",
	"robot_right",
	"robot_left",
	"robot_intake_in",
	"robot_intake_out",
	"robot_intake_toggle",
	"robot_intake_spin_in",
	"robot_intake_spin_out",
	"robot_shoot",
]

func get_action_strength(action) -> float:
	if frame != null and action in frame:
		return frame[action]
	return Input.get_action_strength(action)

func get_frame():
	var result = {}
	for action in frame_actions:
		result[action] = Input.get_action_strength(action)
	return result

func get_zero_frame():
	var result = {}
	for action in frame_actions:
		result[action] = 0
	return result

func set_frame(new_frame):
	frame = new_frame
