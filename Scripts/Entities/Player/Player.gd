extends KinematicBody2D

var MAX_SPEED = 400
var ACCELERATION = 2500
var FRICTION = 2500
var velocity = Vector2()

onready var animationPlayer = $AnimationPlayer

#func _draw(): # show the actual movement vector that's happening 
#	draw_line(Vector2(0, 0), velocity/5, Color(1.0, 0.2, 0.5), 2.0)

#	update()
#func _process(_delta):

func _ready(): # once node entered tree
	randomize()
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var randx = rng.randf_range(150.0, 750.0)
	var randy = rng.randf_range(125.0, 450.0)
	print("random start: (" + str(randx) + "," + str(randy) + ")")
	position = Vector2(randx, randy)

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

		if not Global.isPlayerHost:
				var sendVector = PoolByteArray()
				sendVector.append(256)
				sendVector.append_array(var2bytes({"message":input_vector, "from":Global.STEAM_ID}))
#				$"../Multiplayer"._send_P2P_Packet(sendVector, 1, 0)		
		
		velocity = move_and_slide(velocity)

