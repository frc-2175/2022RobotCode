extends Spatial

class_name Robot

var start_with_max_air = true

var system_air_volume_cm3: float
var extra_air_volume_cm3: float = 0.0

var atmospheric_pressure_Npcm2 = 10.13

var intake_in: bool = true

export(String, FILE, "*.json") var recording: String
var is_recording: bool = false
var is_playing: bool = false
var recording_frames = []
var playback_frames = []
var playback_index = 0

var input = RobotInput.new()

func get_lookat_position():
	return $Chassis.global_transform.origin

func _ready():
	system_air_volume_cm3 = get_system_air_volume_cm3()
	if start_with_max_air:
		extra_air_volume_cm3 = pressure_Npcm2_to_extra_air_volume_cm3(Math.psi2Npcm2(120) + atmospheric_pressure_Npcm2)

	if len(recording) > 0:
		input.set_frame(input.get_zero_frame())
		
		var file = File.new()
		file.open(recording, File.READ)
		var content = file.get_as_text()
		file.close()
		playback_frames = JSON.parse(content).result

func get_volume_scale(extra_cm3: float = extra_air_volume_cm3):
	if system_air_volume_cm3 == 0 or extra_cm3 == 0:
		return 1.0

	return system_air_volume_cm3 / (system_air_volume_cm3 + extra_cm3)

func get_air_pressure_Npcm2(extra_cm3: float = extra_air_volume_cm3) -> float:
	if system_air_volume_cm3 == 0:
		return 0.0

	return atmospheric_pressure_Npcm2 / get_volume_scale(extra_cm3)

func get_working_pressure_Npcm2() -> float:
	return min(Math.psi2Npcm2(60), get_air_pressure_Npcm2())

func get_system_air_volume_cm3(node: Node = null) -> float:
	if not node:
		node = self
	
	var total: float = 0.0
	if node.has_method("get_air_volume_cm3"):
		total += node.get_air_volume_cm3()
	for child in node.get_children():
		total += get_system_air_volume_cm3(child)
	
	return total

# I dunno man, I just did some algebra and this came out
func pressure_Npcm2_to_extra_air_volume_cm3(pressure_Npcm2: float) -> float:
	return ((pressure_Npcm2 * system_air_volume_cm3) / atmospheric_pressure_Npcm2) - system_air_volume_cm3

# awkwardly fit to this data:
# https://www.andymark.com/products/air-compressor?via=Z2lkOi8vYW5keW1hcmsvV29ya2FyZWE6Ok5hdmlnYXRpb246OlNlYXJjaFJlc3VsdHMvJTdCJTIycSUyMiUzQSUyMmNvbXByZXNzb3IlMjIlN0Q
# using this desmos:
# https://www.desmos.com/calculator/iwmfznaobj
func compressor_flow_rate_cfm(psi: float) -> float:
	return (0.7 / (0.15 * psi + 1)) + 0.22

func vent_working_air_cm3(volume_cm3):
	var adjusted_volume = volume_cm3 / get_volume_scale()
	extra_air_volume_cm3 = max(0, extra_air_volume_cm3 - adjusted_volume)

var intake_toggle_active: bool = false
var recording_toggle_active: bool = false

func _process(delta):
	if Input.get_action_strength("input_recording_play") > 0:
		is_playing = true
	
	if is_playing and playback_index < len(playback_frames):
		input.set_frame(playback_frames[playback_index])
		playback_index += 1
	
	var current_pressure_psi = Math.Npcm22psi(get_air_pressure_Npcm2() - atmospheric_pressure_Npcm2)
	if current_pressure_psi < 120:
		var current_flow_rate_cfm = compressor_flow_rate_cfm(current_pressure_psi)
		var current_flow_rate_cm3ps = Math.cfm2cm3ps(current_flow_rate_cfm)
		var new_air_cm3 = current_flow_rate_cm3ps * delta
		extra_air_volume_cm3 += new_air_cm3
	
	if input.get_action_strength("robot_intake_in") > 0:
		intake_in = true
	elif input.get_action_strength("robot_intake_out") > 0:
		intake_in = false
	elif !intake_toggle_active and input.get_action_strength("robot_intake_toggle") > 0:
		intake_in = !intake_in
	
	if !recording_toggle_active and Input.get_action_strength("input_recording_toggle") > 0:
		is_recording = not is_recording
	
	intake_toggle_active = input.get_action_strength("robot_intake_toggle") > 0
	recording_toggle_active = Input.get_action_strength("input_recording_toggle") > 0
	
	record_inputs()

func curvature_speed() -> float:
	return input.get_action_strength("robot_forward") - input.get_action_strength("robot_backward")

func curvature_turn() -> float:
	return input.get_action_strength("robot_right") - input.get_action_strength("robot_left")

# Direct port from the WPILib source
func curvature_drive() -> Vector2:
	var xSpeed: float = curvature_speed()
	var zRotation: float = curvature_turn()

	var angularPower: float
	var overPower: bool

	var isQuickTurn: bool = abs(xSpeed) < 0.1

	if isQuickTurn:
		overPower = true
		angularPower = zRotation
	else:
		overPower = false
		angularPower = abs(xSpeed) * zRotation

	var leftMotorOutput: float = xSpeed + angularPower
	var rightMotorOutput: float = xSpeed - angularPower

	# If rotation is overpowered, reduce both outputs to within acceptable range
	if overPower:
		if leftMotorOutput > 1.0:
			rightMotorOutput -= leftMotorOutput - 1.0
			leftMotorOutput = 1.0
		elif rightMotorOutput > 1.0:
			leftMotorOutput -= rightMotorOutput - 1.0
			rightMotorOutput = 1.0
		elif leftMotorOutput < -1.0:
			rightMotorOutput -= leftMotorOutput + 1.0
			leftMotorOutput = -1.0
		elif rightMotorOutput < -1.0:
			leftMotorOutput -= rightMotorOutput + 1.0
			rightMotorOutput = -1.0

	# Normalize the wheel speeds
	var maxMagnitude: float = max(abs(leftMotorOutput), abs(rightMotorOutput))
	if maxMagnitude > 1.0:
		leftMotorOutput /= maxMagnitude
		rightMotorOutput /= maxMagnitude

	return Vector2(leftMotorOutput, -rightMotorOutput)

func intake_spin_speed():
	return input.get_action_strength("robot_intake_spin_in") - input.get_action_strength("robot_intake_spin_out")

func record_inputs():
	if is_recording:
		recording_frames.append(input.get_frame())
	elif len(recording_frames) > 0:
		var json = JSON.print(recording_frames)
		var file = File.new()
		file.open("res://recordings/%d.json" % OS.get_unix_time(), File.WRITE)
		file.store_string(json)
		file.close()
		
		recording_frames = []
