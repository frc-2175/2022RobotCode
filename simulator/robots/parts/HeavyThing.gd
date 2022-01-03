tool
extends CollisionShape

enum Thing { Battery, CIM_Motor, Compressor }
export(Thing) var thing

var dimensions_m = {
	Thing.Battery: [0.1803, 0.1671, 0.0762],
	Thing.CIM_Motor: [0.1096, 0.0644, 0.0644],
	Thing.Compressor: [0.1509, 0.1151, 0.0536],
}

var masses_kg = {
	Thing.Battery: 5.6699,
	Thing.CIM_Motor: 1.2701,
	Thing.Compressor: 1.0886,
}

func get_mass_kg() -> float:	
	return masses_kg[thing]

func _ready():
	var body: RigidBody = get_parent()
	if body:
		RobotUtil.apply_center_of_mass_to_body(body)
	else:
		printerr("Node ", self.name, " needs to be a child of a RigidBody.")

func _editor_process():
	var dim = dimensions_m[thing]
	var w = dim[0]
	var h = dim[1]
	var d = dim[2]
	
	RobotUtil.reset_scale(self)
	self.shape.extents = Vector3(w/2, h/2, d/2)
	
	var mesh = $Mesh as MeshInstance
	mesh.scale = Vector3(w/2, h/2, d/2)
	
	var body = get_parent()
	if body is RigidBody:
		RobotUtil.apply_mass_to_body(body)

func _process(_delta):
	if Engine.editor_hint:
		_editor_process()
