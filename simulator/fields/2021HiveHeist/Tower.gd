extends MeshInstance

onready var rings = [$Ring1, $Ring2, $Ring3, $Ring4]
var nextRing = 0;

func _on_Trigger_body_entered(body):
	if nextRing >= len(rings):
		return

	var ring = rings[nextRing]
	
	for gamePiece in ring.get_children():
		(gamePiece as RigidBody).mode = RigidBody.MODE_RIGID
	
	nextRing += 1
