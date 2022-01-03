extends Spatial

# To make this work correctly, point the X axis to the robot's right, and point
# the Y axis up. It doesn't align with the X, Y, and Z axes that are in the NavX
# manual, but it avoids more Godot weirdness. Euler angles are very annoying.

onready var sim = RobotUtil.find_parent_by_script(self, SimClient) as SimClient
onready var initial_basis: Basis = self.global_transform.basis

func _physics_process(delta):
	var relative_basis = initial_basis.inverse() * self.global_transform.basis
	var rotation = relative_basis.get_euler()
	
	# Fortunately, Godot already reports angles in -Pi to Pi, which is exactly
	# what the navX reports. No need to calculate that ourselves!
	sim.send_data("SimDevices", "navX-Sensor[0]", {
		"<>Pitch": rad2deg(rotation.x),
		"<>Yaw": rad2deg(-rotation.y),
		"<>Roll": rad2deg(rotation.z),
	})
	
	# TODO: Acceleration
