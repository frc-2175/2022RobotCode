extends Camera

export(NodePath) var target

onready var target_node = get_node(target) as Spatial

func _process(_delta):
	if target_node:
		var pos = target_node.global_transform.origin
		if target_node.has_method("get_lookat_position"):
			pos = target_node.get_lookat_position()
		look_at(pos, Vector3.UP)
