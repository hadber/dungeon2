extends KinematicBody2D

# var speed = 400  # speed in pixels/sec
# var velocity = Vector2.ZERO

var MAX_SPEED = 400
var ACCELERATION = 2000
var motion = Vector2() # motion on the cartesian plane


func get_input_axis():
	var axis = Vector2.ZERO
	axis.x = Input.get_action_strength("right") - Input.get_action_strength("left") 
	axis.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	return axis.normalized() # prevent moving faster on diagonal than on cartesian directions

func apply_friction(amount):
	if motion.length() > amount:
		motion -= motion.normalized() * amount 
	else:
		motion = Vector2.ZERO

func apply_movement(acceleration):
	motion += acceleration
	motion = motion.clamped(MAX_SPEED)

func _physics_process(delta):
	var axis = get_input_axis()
	if(axis == Vector2.ZERO):
		apply_friction(ACCELERATION * delta)
	elif(axis.x == 0):
		motion.x -= motion.normalized().x * ACCELERATION * delta
		apply_movement(axis * ACCELERATION * delta)
	elif(axis.y == 0):
		motion.y -= motion.normalized().y * ACCELERATION * delta
		apply_movement(axis * ACCELERATION * delta)
	else:
		apply_movement(axis * ACCELERATION * delta)
	motion = move_and_slide(motion)
#	print(motion)

