tool
extends CollisionShape

class_name RobotBox

export(String, "Aluminum", "Polycarb", "Steel") var material = "Aluminum"

export(Math.LengthUnit) var unit = Math.LengthUnit.Inches setget set_unit
export(float) var width = 2
export(float) var height = 1
export(float) var depth = 12

export(float, 0.03125, 0.25) var thickness_inches = 0.125
export(bool) var solid = false

export(Material) var visual_material

export(bool) var recreate_children = false

var resource_cache = {}
func load_resource(path):
	if not path in resource_cache:
		resource_cache[path] = load(path)
	return resource_cache[path]

func set_unit(new_unit):
	var wm = Math.length2m(width, unit)
	var hm = Math.length2m(height, unit)
	var dm = Math.length2m(depth, unit)
	width = Math.m2length(wm, new_unit)
	height = Math.m2length(hm, new_unit)
	depth = Math.m2length(dm, new_unit)
	
	unit = new_unit
	property_list_changed_notify()

func ensure_children():
	if recreate_children:
		recreate_children = false
		self.remove_child($Mesh)
	
	var mesh: MeshInstance = get_node_or_null(@"Mesh")
	if not mesh:
		mesh = MeshInstance.new()
		mesh.mesh = CubeMesh.new()
		mesh.name = "Mesh"
		self.add_child(mesh)
		mesh.owner = get_tree().get_edited_scene_root()

func get_mass_kg() -> float:
	var w = Math.length2m(width, unit)
	var h = Math.length2m(height, unit)
	var d = Math.length2m(depth, unit)
	var volume_m3 = w * h * d
	if not solid:
		var w2 = Math.length2m(width, unit) - Math.in2m(thickness_inches*2)
		var h2 = Math.length2m(height, unit) - Math.in2m(thickness_inches*2)
		var d2 = Math.length2m(depth, unit) - Math.in2m(thickness_inches*2)
		volume_m3 -= w2 * h2 * d2
	var density_kgpm3 = RobotUtil.get_materials()[material].density_kgpm3
	
	return volume_m3 * density_kgpm3

func _ready():
	var body: RigidBody = get_parent()
	if body:
		RobotUtil.apply_center_of_mass_to_body(body)
	else:
		printerr("Node ", self.name, " needs to be a child of a RigidBody.")

func _editor_process():
	ensure_children()
	
	var w = Math.length2m(width, unit)
	var h = Math.length2m(height, unit)
	var d = Math.length2m(depth, unit)
	
	if not self.shape:
		self.shape = BoxShape.new()
	RobotUtil.reset_scale(self)
	self.shape.extents = Vector3(w/2, h/2, d/2)
	
	var mesh = $Mesh as MeshInstance
	RobotUtil.reset_translation(mesh)
	RobotUtil.reset_rotation(mesh)
	RobotUtil.reset_children(mesh)
	mesh.scale = Vector3(w/2, h/2, d/2)
	if visual_material:
		mesh.mesh.surface_set_material(0, visual_material)
	else:
		mesh.mesh.surface_set_material(0, load_resource(RobotUtil.get_materials()[material].material_path))
	
	var body: RigidBody = get_parent()
	if body:
		RobotUtil.apply_mass_to_body(body)
		RobotUtil.set_collision_data(body)
	else:
		printerr("Node ", self.name, " needs to be a child of a RigidBody.")

func _process(_delta):
	if Engine.editor_hint:
		_editor_process()
