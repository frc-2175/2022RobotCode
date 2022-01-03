tool
extends Spatial

export(NodePath) var root
onready var label = $Label3D

func add_masses(node: Node):
	var result = 0
	if node is RigidBody:
		result += node.mass
	for child in node.get_children():
		result += add_masses(child)
	return result

func _process(_delta):
	var mass = add_masses(get_node(root) if root else get_parent())
	mass = round(Math.kg2lb(mass) * 100) / 100
	label.text = str(mass) + " lb"
