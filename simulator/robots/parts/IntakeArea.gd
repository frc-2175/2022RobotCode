extends Area

class_name IntakeArea

export(NodePath) var launcher
onready var _launcher: IntakeLauncher = get_node(launcher) as IntakeLauncher

func _ready():
	connect("body_entered", self, "_on_body_entered")

func _on_body_entered(body: Node):
	if not (body is RigidBody):
		printerr("A IntakeArea should only detect RigidBody nodes, but detected %s (%s)" % [body.name, body])
		return
	_launcher.store(body)
