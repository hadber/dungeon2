extends KinematicBody2D

var MAX_SPEED = 400
var ACCELERATION = 2500
var FRICTION = 2500
var velocity = Vector2()

onready var animationPlayer = $AnimationPlayer

#func _draw(): # show the actual movement vector that's happening 
#	draw_line(Vector2(0, 0), velocity/5, Color(1.0, 0.2, 0.5), 2.0)

#func _process(_delta):
#	update()

func _ready(): # once node entered tree
	position = Vector2(400, 300)

func _physics_process(delta):
	
	if not Global.in_dialogue:
		var input_vector = Vector2.ZERO
		input_vector.x = Input.get_action_strength("right") - Input.get_action_strength("left")
		input_vector.y = Input.get_action_strength("down") - Input.get_action_strength("up")
		input_vector = input_vector.normalized()
		
		if input_vector != Vector2.ZERO:
			animationPlayer.play("Run")
			velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
		else:
			animationPlayer.play("Idle")
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		
		velocity = move_and_slide(velocity)
