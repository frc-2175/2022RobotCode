extends Node

class_name RobotUtil

static func get_materials():
	return {
		Aluminum = {
			density_kgpm3 = 2700,
			material_path = "res://assets/materials/SimpleAluminumMaterial.tres",
		},
		Polycarb = {
			density_kgpm3 = 1360,
			material_path = "res://assets/materials/DirtyGlassMaterial.tres",
		},
		Steel = {
			density_kgpm3 = 7859,
			material_path = "res://assets/materials/SimpleSteelMaterial.tres",
		},
		Rubber = {
			density_kgpm3 = 1500, # totally made up!
			material_path = "res://assets/materials/SimpleRubberMaterial.tres",
		},
	}

static func reset_translation(node: Spatial):
	if node.translation != Vector3(0, 0, 0):
		printerr("Don't move the node '%s' directly; move its parent, '%s'." % [node.name, node.get_parent().name])
	node.translation = Vector3(0, 0, 0)

static func reset_rotation(node: Spatial):
	if node.rotation != Vector3(0, 0, 0):
		printerr("Don't rotate the node '%s' directly; rotate its parent, '%s'." % [node.name, node.get_parent().name])
	node.rotation = Vector3(0, 0, 0)

static func reset_scale(node: Spatial):
	if node.scale != Vector3(1, 1, 1):
		printerr("Don't scale the node '%s' directly; scale its parent, '%s'." % [node.name, node.get_parent().name])
	node.scale = Vector3(1, 1, 1)

static func reset_children(node: Node):
	if node.get_child_count() > 0:
		printerr("Don't add children to node '%s'." % node.name)
	for child in node.get_children():
		node.remove_child(child)
		node.get_parent().add_child(child)
		child.owner = node.get_tree().get_edited_scene_root()

static func find_parent_by_script(node: Node, script: Script):
	if not node:
		return null
	if node.get_script() == script:
		return node
	return find_parent_by_script(node.get_parent(), script)

# Walk through a node's children, adding up the masses.
static func get_mass(node: RigidBody) -> float:
	var sum: float = 0	
	for child in node.get_children():
		if child.has_method("get_mass_kg"):
			sum += child.get_mass_kg()
	return sum

# Gets a node's center of mass in world coordinates.
static func get_center_of_mass(node: RigidBody) -> Vector3:
	var didInitialize: bool = false
	var center: Vector3 = Vector3(0, 0, 0)
	var total_mass: float = 0.0
	
	for child in node.get_children():
		if child.has_method("get_mass_kg"):
			child = child as Spatial
			if not didInitialize:
				# initialize!
				center = child.global_transform.origin
				total_mass = child.get_mass_kg()
				didInitialize = true
			else:
				var new_total_mass = total_mass + child.get_mass_kg()
				center = lerp(center, child.global_transform.origin, 1 - (total_mass / new_total_mass))
				total_mass = new_total_mass
	
	return center

static func apply_mass_to_body(body: RigidBody):
	body.mass = get_mass(body)
	body.can_sleep = false

static func apply_center_of_mass_to_body(body: RigidBody):
	var center_of_mass = get_center_of_mass(body)
	var body_translate = center_of_mass - body.global_transform.origin

	body.global_translate(body_translate)
	for child in body.get_children():
		if child is Spatial:
			child.global_translate(-body_translate)

static func set_collision_data(body: RigidBody):
	body.collision_layer = (1 << 2)
	body.collision_mask = (1 << 0) | (1 << 2)
		
	var has_intake_wheels = false
	for child in body.get_children():
		child = child as Node
		if child.get("is_intake_wheel"):
			has_intake_wheels = true

	body.set_collision_layer_bit(3, not has_intake_wheels)
	body.set_collision_layer_bit(4, has_intake_wheels)
