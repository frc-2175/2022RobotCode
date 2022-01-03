tool
extends CollisionShape

class_name RobotCylinder

export(String, "Aluminum", "Polycarb", "Steel", "Rubber") var material = "Aluminum"

export(float, 0.25, 2) var radius_inches = 1
export(float, 1, 60) var length_inches = 12

export(float, 0.03125, 0.25) var thickness_inches = 0.125
export(bool) var solid = false

export(bool) var is_intake_wheel = false

export(bool) var recreate_children = false

var resource_cache = {}
func load_resource(path):
	if not path in resource_cache:
		resource_cache[path] = load(path)
	return resource_cache[path]

func get_mass_kg():
	var r = Math.in2m(radius_inches)
	var volume_m3 = PI*r*r * Math.in2m(length_inches)
	if not solid:
		var r2 = Math.in2m(radius_inches-thickness_inches*2)
		volume_m3 -= PI*r2*r2 * Math.in2m(length_inches)
	var density_kgpm3 = RobotUtil.get_materials()[material].density_kgpm3
	
	return volume_m3 * density_kgpm3

func ensure_children():
	if recreate_children:
		recreate_children = false
		self.remove_child($Mesh)
		self.remove_child($Start)
		self.remove_child($End)
		
	var mesh = get_node_or_null(@"Mesh")
	if not mesh:
		mesh = MeshInstance.new()
		mesh.mesh = CylinderMesh.new()
		mesh.name = "Mesh"
		self.add_child(mesh)
		mesh.owner = get_tree().get_edited_scene_root()
	
	var start = get_node_or_null(@"Start")
	if not start:
		start = Spatial.new()
		start.name = "Start"
		self.add_child(start)
		start.owner = get_tree().get_edited_scene_root()
		
	var end = get_node_or_null(@"End")
	if not end:
		end = Spatial.new()
		end.name = "End"
		self.add_child(end)
		end.owner = get_tree().get_edited_scene_root()

func _ready():
	var body: RigidBody = get_parent()
	if body:
		RobotUtil.apply_center_of_mass_to_body(body)
	else:
		printerr("Node ", self.name, " needs to be a child of a RigidBody.")

func _editor_process():
	ensure_children()
	
	var r = Math.in2m(radius_inches)
	var h = Math.in2m(length_inches)
	
	if not self.shape:
		self.shape = CylinderShape.new()
	RobotUtil.reset_scale(self)
	self.shape.height = h
	self.shape.radius = r
	
	var mesh = $Mesh as MeshInstance
	RobotUtil.reset_translation(mesh)
	RobotUtil.reset_rotation(mesh)
	RobotUtil.reset_children(mesh)
	mesh.scale = Vector3(r, h/2, r)
	mesh.mesh.surface_set_material(0, load_resource(RobotUtil.get_materials()[material].material_path))
	
	var start = $Start as Spatial
	start.translation = Vector3(0, -h/2, 0)
	RobotUtil.reset_rotation(start)
	RobotUtil.reset_scale(start)
	
	var end = $End as Spatial
	end.translation = Vector3(0, h/2, 0)
	RobotUtil.reset_rotation(end)
	RobotUtil.reset_scale(end)
	
	var body: RigidBody = get_parent()
	if body:
		RobotUtil.apply_mass_to_body(body)
		RobotUtil.set_collision_data(body)
	else:
		printerr("Node ", self.name, " needs to be a child of a RigidBody.")

func _process(_delta):
	if Engine.editor_hint:
		return _editor_process()
