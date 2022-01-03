tool
extends StaticBody

export(Color, RGB) var color = Color(0.6, 0.6, 0.6)

export(Math.LengthUnit) var unit = Math.LengthUnit.Inches setget set_unit
export(float) var width = 24
export(float) var height = 12
export(float) var depth = 24

var mat: SpatialMaterial

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
	mesh.scale = Vector3(w/2, h/2, d/2)
	
	update_color()

func _ready():
	update_color()

func _process(_delta):
	if Engine.editor_hint:
		_editor_process()

func update_color():
	if not mat:
		mat = SpatialMaterial.new()
	
	$Mesh.mesh.material = mat
	mat.albedo_color = color
