extends Object

class_name SimVictorSPX

var sim: SimClient
var device_number: int

var id = "Victor SPX[%d]" % device_number

func _init(sim: SimClient, device_number: int):
	self.sim = sim
	self.device_number = device_number

func get_percent_output() -> float:
	return sim.get_data("CANMotor", id, "<percentOutput", 0.0)

func set_bus_voltage(value: float) -> void:
	sim.send_data("CANMotor", id, {
		">busVoltage": value,
	})
