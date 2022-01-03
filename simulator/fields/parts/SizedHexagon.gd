tool
extends StaticBody

export(Color, RGB) var color = Color(0.6, 0.6, 0.6)

export(Math.LengthUnit) var unit = Math.LengthUnit.Feet setget set_unit
export(float) var width = 1.732
export(float) var height = 1
export(float) var depth = 2

var mat: SpatialMaterial

var widthDepthRatio = 0.8661

func set_unit(new_unit):
	var wm = Math.length2m(width, unit)
	var hm = Math.length2m(height, unit)
	var dm = Math.length2m(depth, unit)
	width = Math.m2length(wm, new_unit)
	height = Math.m2length(hm, new_unit)
	depth = Math.m2length(dm, new_unit)
	
	unit = new_unit
	property_list_changed_notify()

func _editor_process():		
	var w = Math.length2m(width, unit)
	var h = Math.length2m(height, unit)
	var d = Math.length2m(depth, unit)
	
	RobotUtil.reset_scale(self)
	$Collision.shape.extents = Vector3(w/2, h/2, d/2)
	
	var mesh = $Mesh as MeshInstance
	RobotUtil.reset_translation(mesh)
	RobotUtil.reset_rotation(mesh)
	RobotUtil.reset_children(mesh)
	mesh.scale = Vector3(w/2 / widthDepthRatio, h/2, d/2)
	
	update_color()

func _ready():
	update_color()

func _process(_delta):
	if Engine.editor_hint:
		_editor_process()

func update_color():
	if not mat:
		mat = SpatialMaterial.new()
	
	$Mesh.set_surface_material(0, mat)
	mat.albedo_color = color
