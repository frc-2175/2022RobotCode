extends RigidBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

var weld = null

func _on_Hooked_body_entered(body):
	if body == self:
		return
	if weld != null:
		return

	weld = PinJoint.new()
	print(body)
	$Hooked.add_child(weld)
	weld.set_node_a(self.get_path())
	weld.set_node_b(body.get_path())
	$Piston2Hook.get_parent().remove_child($Piston2Hook)
