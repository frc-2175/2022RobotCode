extends Object

class_name SimDoubleSolenoid

enum Value { Off, Forward, Reverse }

var sim: SimClient
var forward_channel: int
var reverse_channel: int
var pcm_id: int

var forward_id = "%d,%d" % [pcm_id, forward_channel]
var reverse_id = "%d,%d" % [pcm_id, reverse_channel]

func _init(sim: SimClient, forward_channel: int, reverse_channel: int, module_number: int = 0):
	self.sim = sim
	self.forward_channel = forward_channel
	self.reverse_channel = reverse_channel
	self.pcm_id = module_number

func get_value() -> int:
	var forward_on = sim.get_data("Solenoid", forward_id, "<output", false)
	var reverse_on = sim.get_data("Solenoid", reverse_id, "<output", false)
	
	if not forward_on and not reverse_on:
		return Value.Off
	elif forward_on:
		return Value.Forward
	else:
		return Value.Reverse
