tool
extends Spatial

class_name Piston

export(float) var bore_diameter_inches = 0.88
export(float) var length_inches = 12

enum SolenoidType { Solenoid, DoubleSolenoid }
export(SolenoidType) var solenoid_type = SolenoidType.Solenoid
export(int) var single_channel = 0 # use only with single solenoid
export(int) var double_forward_channel = 0 # use only with double solenoid
export(int) var double_reverse_channel = 0 # use only with double solenoid

onready var robot: Robot = RobotUtil.find_parent_by_script(self, Robot) as Robot
onready var sim: SimClient = RobotUtil.find_parent_by_script(self, SimClient)
onready var _piston_base: RigidBody = $Base
onready var _piston_rod: RigidBody = $Rod

export(bool) var is_intake = false

var sim_solenoid

var lbf2n = 4.448
var efficiency = 0.85
var retract_ratio = 0.89

func get_air_volume_cm3():
	var bore_area_cm2 = PI * Math.in2cm(bore_diameter_inches/2) * Math.in2cm(bore_diameter_inches/2)
	return bore_area_cm2 * Math.in2cm(length_inches - 1 ) # Sub 1 for plunger. Not really accurate but whatever?

func ensure_children():
	var base = get_node_or_null(@"Base")
	if not base:
		base = RigidBody.new()
		base.name = "Base"
		self.add_child(base)
		base.owner = get_tree().get_edited_scene_root()
	
	var base_cylinder = get_node_or_null(@"Base/Cylinder")
	if not base_cylinder:
		base_cylinder = RobotCylinder.new()
		base_cylinder.name = "Cylinder"
		base.add_child(base_cylinder)
		base_cylinder.owner = get_tree().get_edited_scene_root()
	
	var slider = get_node_or_null(@"Base/SliderJoint")
	if not slider:
		slider = SliderJoint.new()
		slider.name = "SliderJoint"
		base.add_child(slider)
		slider.owner = get_tree().get_edited_scene_root()
	
	var rod = get_node_or_null(@"Rod")
	if not rod:
		rod = RigidBody.new()
		rod.name = "Rod"
		self.add_child(rod)
		rod.owner = get_tree().get_edited_scene_root()

	var rod_cylinder = get_node_or_null(@"Rod/Cylinder")
	if not rod_cylinder:
		rod_cylinder = RobotCylinder.new()
		rod_cylinder.name = "Cylinder"
		rod.add_child(rod_cylinder)
		rod_cylinder.owner = get_tree().get_edited_scene_root()

func _editor_process():
	ensure_children()

	var base: RigidBody = $Base
	base.translation = Vector3(0, Math.in2m(length_inches/2), 0)
	RobotUtil.reset_rotation(base)
	RobotUtil.reset_scale(base)
	
	var base_cylinder: RobotCylinder = $Base/Cylinder
	RobotUtil.reset_translation(base_cylinder)
	RobotUtil.reset_rotation(base_cylinder)
	RobotUtil.reset_scale(base_cylinder)
	base_cylinder.radius_inches = (bore_diameter_inches/2) + 0.5
	base_cylinder.length_inches = length_inches
	base_cylinder.solid = false
	
	var rod: RigidBody = $Rod
	rod.translation = Vector3(0, Math.in2m(length_inches/2 + 1), 0)
	RobotUtil.reset_rotation(rod)
	RobotUtil.reset_scale(rod)
	
	var rod_cylinder: RobotCylinder = $Rod/Cylinder
	RobotUtil.reset_translation(rod_cylinder)
	RobotUtil.reset_rotation(rod_cylinder)
	RobotUtil.reset_scale(rod_cylinder)
	rod_cylinder.radius_inches = base_cylinder.radius_inches * 0.5
	rod_cylinder.length_inches = length_inches + 1
	rod_cylinder.solid = true
	
	var slider: SliderJoint = $Base/SliderJoint
	slider.translation = Vector3(0, Math.in2m(1), 0)
	slider.rotation = Vector3(0, 0, deg2rad(90))
	RobotUtil.reset_scale(slider)
	RobotUtil.reset_children(slider)
	slider.set_node_a(@"../../Base")
	slider.set_node_b(@"../../Rod")
	slider.set_param(SliderJoint.PARAM_LINEAR_LIMIT_UPPER, Math.in2m(length_inches - 1))
	slider.set_param(SliderJoint.PARAM_LINEAR_LIMIT_LOWER, 0)
	slider._set_upper_limit_angular(10)
	slider._set_lower_limit_angular(-10)

func _ready():
	if solenoid_type == SolenoidType.Solenoid:
		sim_solenoid = SimSolenoid.new(sim, single_channel)
	elif solenoid_type == SolenoidType.DoubleSolenoid:
		sim_solenoid = SimDoubleSolenoid.new(sim, double_forward_channel, double_reverse_channel)
	else:
		printerr("Unrecognized solenoid type: ", solenoid_type)

func _process(_delta):
	if Engine.editor_hint:
		return _editor_process()

var last_forward: bool = false

func _physics_process(_delta):
	if Engine.editor_hint:
		return

	if sim.connected and solenoid_type == SolenoidType.DoubleSolenoid and sim_solenoid.get_value() == SimDoubleSolenoid.Value.Off:
		pass # do nothing, neither side is pressurized
	else:
		var forward = get_forward()
		var sgn = 1 if forward else -1
		var retract_reduction = 1 if forward else retract_ratio
		
		if forward != last_forward:
			robot.vent_working_air_cm3(get_air_volume_cm3())
		
		var psi = Math.Npcm22psi(robot.get_working_pressure_Npcm2() - robot.atmospheric_pressure_Npcm2)
		var pressure_area_square_inches = PI*(bore_diameter_inches/2)*(bore_diameter_inches/2)
		var force_lbf = psi * pressure_area_square_inches
		var force_n = force_lbf * lbf2n * efficiency
		var force = force_n * retract_reduction
		
		_piston_base.add_central_force(-sgn * _piston_base.global_transform.basis.y * force)
		_piston_rod.add_central_force(sgn * _piston_base.global_transform.basis.y * force)
		
		last_forward = forward

func get_forward() -> bool:
	if sim.connected:
		if solenoid_type == SolenoidType.Solenoid:
			return sim_solenoid.get_output()
		else:
			return sim_solenoid.get_value() == SimDoubleSolenoid.Value.Forward
	else:
		return !robot.intake_in
