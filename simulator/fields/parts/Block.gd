tool
extends StaticBody

export(Color, RGB) var color = Color(0.6, 0.6, 0.6)

var mesh: CubeMesh
var mat: SpatialMaterial

func _editor_process():
	update_color()

func _ready():
	update_color()
	set_process(false)

func _process(_delta):
	if Engine.editor_hint:
		return _editor_process()

func update_color():
	if not mat:
		mat = SpatialMaterial.new()
	if not mesh:
		mesh = CubeMesh.new()
	
	$MeshInstance.mesh = mesh
	mesh.material = mat
	mat.albedo_color = color
