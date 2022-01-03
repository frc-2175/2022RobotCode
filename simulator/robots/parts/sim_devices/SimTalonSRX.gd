extends Object

class_name SimTalonSRX

var sim: SimClient
var device_number: int

var base_id: String = "Talon SRX[%d]" % device_number
var analog_in_id: String = "Talon SRX[%d]/Analog In" % device_number
var pw_input_id: String = "Talon SRX[%d]/Pulse Width Input" % device_number
var encoder_id: String = "Talon SRX[%d]/Quad Encoder" % device_number
var fwd_limit_id: String = "Talon SRX[%d]/Fwd Limit" % device_number
var rev_limit_id: String = "Talon SRX[%d]/Rev Limit" % device_number

func _init(sim: SimClient, device_number: int):
	self.sim = sim
	self.device_number = device_number

func get_percent_output() -> float:
	return sim.get_data("CANMotor", base_id, "<percentOutput", 0.0)

func set_supply_current(value: float) -> void:
	sim.send_data("CANMotor", base_id, {
		">supplyCurrent": value,
	})

func set_motor_current(value: float) -> void:
	sim.send_data("CANMotor", base_id, {
		">motorCurrent": value,
	})

func set_bus_voltage(value: float) -> void:
	sim.send_data("CANMotor", base_id, {
		">busVoltage": value,
	})

func get_analog_in_init() -> bool:
	return sim.get_data("CANAIn", analog_in_id, "<init", 0) > 0

func set_analog_in_voltage(value: float) -> void:
	sim.send_data("CANAIn", analog_in_id, {
		">voltage": value,
	})

func set_pulse_width_input_connected(value: bool) -> void:
	sim.send_data("CANDutyCycle", pw_input_id, {
		">connected": value,
	})

func set_pulse_width_input_position(value: float) -> void:
	sim.send_data("CANDutyCycle", pw_input_id, {
		">position": value,
	})
	
func get_encoder_position() -> float:
	return sim.get_data("CANEncoder", encoder_id, "<position", 0.0)

func set_encoder_raw_position_input(value: float) -> void:
	sim.send_data("CANEncoder", encoder_id, {
		">rawPositionInput": value,
	})

func set_encoder_velocity(value: float) -> void:
	sim.send_data("CANEncoder", encoder_id, {
		">velocity": value,
	})

func get_fwd_limit_init() -> bool:
	return sim.get_data("CANDIO", fwd_limit_id, "<init", 0) > 0

func get_fwd_limit_input() -> bool:
	return sim.get_data("CANDIO", fwd_limit_id, "<input", 0) > 0

func get_fwd_limit_value() -> bool:
	return sim.get_data("CANDIO", fwd_limit_id, "<>value", 0) > 0

func set_fwd_limit_value(value: bool) -> void:
	sim.send_data("CANDIO", fwd_limit_id, {
		"<>value": value,
	})

func get_rev_limit_init() -> bool:
	return sim.get_data("CANDIO", rev_limit_id, "<init", 0) > 0

func get_rev_limit_input() -> bool:
	return sim.get_data("CANDIO", rev_limit_id, "<input", 0) > 0

func get_rev_limit_value() -> bool:
	return sim.get_data("CANDIO", rev_limit_id, "<>value", 0) > 0

func set_rev_limit_value(value: bool) -> void:
	sim.send_data("CANDIO", rev_limit_id, {
		"<>value": value,
	})
