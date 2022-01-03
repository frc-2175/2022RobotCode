extends Object

class_name SimSolenoid

var sim: SimClient
var pcm_id: int
var channel: int

var id = "%d,%d" % [pcm_id, channel]

func _init(sim: SimClient, channel: int, module_number: int = 0):
	self.sim = sim
	self.pcm_id = module_number
	self.channel = channel

func get_init() -> bool:
	return sim.get_data("Solenoid", id, "<init", false)

func get_output() -> bool:
	return sim.get_data("Solenoid", id, "<output", false)
