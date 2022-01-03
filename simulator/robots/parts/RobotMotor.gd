extends Spatial

class_name RobotMotor

enum ControllerType {TalonFX, TalonSRX, VictorSPX, PWM}
export(ControllerType) var controller_type
export(int) var motor_id = 1

# see CIM datasheet https://content.vexrobotics.com/docs/217-2000-CIM-motor-specs.pdf
var max_torque = 0.4519 # Newton-meters, from 64 oz-in of torque under normal load
#var max_torque = 1.5 # nah screw math

onready var sim: SimClient = RobotUtil.find_parent_by_script(self, SimClient)
onready var robot: Robot = RobotUtil.find_parent_by_script(self, Robot)
onready var directly_apply: bool = get_parent() as RigidBody != null

export(bool) var is_intake = false

func _physics_process(_delta):
	if directly_apply:
		var body = get_parent() as RigidBody
		var speed = get_speed()
		if abs(speed) > 0.05:
			var torque = speed * max_torque * global_transform.basis.x
			body.add_torque(torque)
		else:
			# Counter-torque to stop rotation
			var torque = -body.angular_velocity * 0.1
			body.add_torque(torque)

func get_speed() -> float:
	if sim.connected:
		match controller_type:
			ControllerType.TalonSRX:
				return SimTalonSRX.new(sim, motor_id).get_percent_output()
			ControllerType.VictorSPX:
				return SimVictorSPX.new(sim, motor_id).get_percent_output()
			_:
				printerr("Unrecognized controller type in wheel: ", controller_type)
				return 0.0
	else:
		return robot.intake_spin_speed()
