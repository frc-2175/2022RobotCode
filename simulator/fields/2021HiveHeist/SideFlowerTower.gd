extends MeshInstance





# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.get_action_strength("DropSideTower") > 0:
		for child in get_children():
			if child is RigidBody:
				(child as RigidBody).mode = RigidBody.MODE_RIGID
