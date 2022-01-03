extends RigidBody

onready var area = $Area as Area
onready var sphere = $RigidCollision.shape as SphereShape

func _physics_process(_delta):
	for body in area.get_overlapping_bodies():
		body = body as RigidBody
		if not body:
			continue
		
		if body.angular_velocity.length() > 0:
			# This method assumes the body's center is inline with the axis of
			# rotation. Which should be a safe assumption, since anything else
			# would mean the center of mass is off-axis, and when the thing rotates
			# it will be wobbly and sad.
			
			var a = body.angular_velocity
			
			var closest_point_on_axis = (
				body.global_transform.origin
				+ (self.global_transform.origin - body.global_transform.origin).project(body.angular_velocity)
			)
			var b = self.global_transform.origin - closest_point_on_axis
			
			var force_direction = a.cross(b).normalized()
			var force_magnitude = body.angular_velocity.length() / 10
			var force_position = self.global_transform.origin + (-b).normalized() * sphere.radius
			
			self.add_force(force_direction * force_magnitude, force_position - self.global_transform.origin)
			body.add_force(-force_direction * force_magnitude, force_position - body.global_transform.origin)
