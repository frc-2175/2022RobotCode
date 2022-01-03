tool
extends Spatial

class_name RobotRuler

var Label3D = preload("res://addons/SIsilicon.3d.text/label_3d.gd")

export(NodePath) var node_a
export(NodePath) var node_b

enum RulerUnit { Inches, Feet, Centimeters }
export(RulerUnit) var unit = RulerUnit.Inches
export(int, 0, 4) var decimal_places = 2

var vertices = PoolVector3Array()
var colors = PoolColorArray()
var arr_mesh = ArrayMesh.new()

var mesh_instance = MeshInstance.new()
var text = Label3D.new()

func get_label():
	var dist_m = (get_node(node_a).global_transform.origin - get_node(node_b).global_transform.origin).length()
	var dist_unit: float
	var unit_text: String
	match unit:
		RulerUnit.Inches:
			dist_unit = Math.m2in(dist_m)
			unit_text = "in"
		RulerUnit.Centimeters:
			dist_unit = dist_m * 100
			unit_text = "cm"
		RulerUnit.Feet:
			dist_unit = Math.m2ft(dist_m)
			unit_text = "ft"
	
	var mul = pow(10, decimal_places)
	dist_unit = round(dist_unit * mul) / mul
	
	return str(dist_unit) + " " + unit_text

func _editor_process():
	if node_a and node_b:
		# Initialize mesh data
		if len(vertices) != 2 or len(colors) != 2:
			vertices.empty()
			vertices.push_back(Vector3(0, 0, 0))
			vertices.push_back(Vector3(0, 0, 0))
			
			colors.empty()
			colors.push_back(Color(0, 0, 0))
			colors.push_back(Color(0, 0, 0))
		
		var translate_a = (get_node(node_a) as Spatial).global_transform.origin - self.global_transform.origin
		var translate_b = (get_node(node_b) as Spatial).global_transform.origin - self.global_transform.origin
		
		vertices[0] = translate_a
		vertices[1] = translate_b
		
		colors[0] = Color.red
		colors[1] = Color.red

		# Update mesh
		if arr_mesh.get_surface_count() > 0:
			arr_mesh.surface_remove(0)
		
		var arrays = []
		arrays.resize(ArrayMesh.ARRAY_MAX)
		arrays[ArrayMesh.ARRAY_VERTEX] = vertices
		arrays[ArrayMesh.ARRAY_COLOR] = colors
		arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, arrays)
		mesh_instance.mesh = arr_mesh
		
		# Update text
		text.text = get_label()
		text.text_size = 0.03
		text.color = Color.black
		text.translation = (translate_a + translate_b) / 2 + Vector3(0, 0.015, 0)
		
		var a_to_b: Vector3 = (translate_b - translate_a).normalized()
		var text_forward: Vector3 = a_to_b.cross(Vector3.UP).normalized()
		var text_up: Vector3 = text_forward.cross(a_to_b)
		text.rotation = Basis(a_to_b, text_up, text_forward).get_euler()

		if mesh_instance.get_parent() != self:
			for child in self.get_children():
				if child is MeshInstance:
					self.remove_child(child)
			self.add_child(mesh_instance)
		
		if text.get_parent() != self:
			for child in self.get_children():
				if child is Label3D:
					self.remove_child(child)
			self.add_child(text)
	else:
		for child in get_children():
			self.remove_child(child)

func _process(_delta):
	if Engine.editor_hint:
		return _editor_process()
