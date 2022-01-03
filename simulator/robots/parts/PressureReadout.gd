extends Spatial

onready var label = $Label3D
onready var robot: Robot = RobotUtil.find_parent_by_script(self, Robot) as Robot

func _process(_delta):
	var psi = Math.Npcm22psi(robot.get_air_pressure_Npcm2() - robot.atmospheric_pressure_Npcm2)
	psi = round(psi * 10) / 10
	label.text = str(psi) + " psi"
