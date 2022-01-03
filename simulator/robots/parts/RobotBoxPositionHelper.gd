tool
extends Spatial

class_name RobotBoxPositionHelper

export(int, "Left", "Center", "Right") var x_position = 1
export(int, "Bottom", "Center", "Top") var y_position = 1
export(int, "Back", "Center", "Front") var z_position = 1

export(NodePath) var box

func _editor_process():
	var _box = get_node(box) if box else get_parent()
	var w = Math.length2m(_box.width, _box.unit)
	var h = Math.length2m(_box.height, _box.unit)
	var d = Math.length2m(_box.depth, _box.unit)
	
	self.global_transform.origin = (
		_box.global_transform.origin
		+ (w/2 * (x_position-1)) * _box.global_transform.basis.x
		+ (h/2 * (y_position-1)) * _box.global_transform.basis.y
		+ (d/2 * (z_position-1)) * _box.global_transform.basis.z
	)
	
func _process(_delta):
	if Engine.editor_hint:
		return _editor_process()
