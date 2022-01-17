extends Generic6DOFJoint

var length
var speed = 0.2

# Called when the node enters the scene tree for the first time.
func _ready():
	length = self.get_param_x(Generic6DOFJoint.PARAM_LINEAR_UPPER_LIMIT)

func _process(delta):
	if Input.get_action_strength("robot_climber_in") > 0:
		length -= speed * delta
	if Input.get_action_strength("robot_climber_out") > 0:
		length += speed * delta
	
	if length < 0:
		length = 0
	
	self.set_param_x(Generic6DOFJoint.PARAM_LINEAR_UPPER_LIMIT, length)
	self.set_param_y(Generic6DOFJoint.PARAM_LINEAR_UPPER_LIMIT, length)
	self.set_param_z(Generic6DOFJoint.PARAM_LINEAR_UPPER_LIMIT, length)
