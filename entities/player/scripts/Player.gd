extends KinematicBody2D

# var speed = 400  # speed in pixels/sec
# var velocity = Vector2.ZERO

var MAX_SPEED = 400
var ACCELERATION = 2000
var motion = Vector2() # motion on the cartesian plane


func get_input_axis():
	var axis = Vector2.ZERO
	axis.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left") 
	axis.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	return axis.normalized() # prevent moving faster on diagonal than on cartesian directions

func apply_friction(amount):
	if motion.length() > amount:
		motion -= motion.normalized() * amount 
	else:
		motion = Vector2.ZERO

func apply_movement(acceleration):
	motion += acceleration
	motion = motion.clamped(MAX_SPEED)
	
"""
func get_input():
	velocity = Vector2.ZERO
	if Input.is_action_pressed('ui_right'):
		velocity.x += 1
	if Input.is_action_pressed('ui_left'):
		velocity.x -= 1
	if Input.is_action_pressed('ui_down'):
		velocity.y += 1
	if Input.is_action_pressed('ui_up'):
		velocity.y -= 1
	# Make sure diagonal movement isn't faster
	velocity = velocity.normalized() * speed
"""

func _physics_process(delta):
	var axis = get_input_axis()
	if(axis == Vector2.ZERO):
		apply_friction(ACCELERATION * delta * 30)
	else:
		apply_movement(axis * ACCELERATION * delta)
	motion = move_and_slide(motion)
	# get_input()
	# velocity = move_and_slide(velocity)
