extends KinematicBody2D

const MAX_SPEED = 400
const ACCELERATION = 2500
const FRICTION = 2500
var velocity = Vector2()
var networked:bool = false

onready var animationPlayer = $AnimationPlayer

#func _draw(): # show the actual movement vector that's happening 
#	draw_line(Vector2(0, 0), velocity/5, Color(1.0, 0.2, 0.5), 2.0)

func spawn_me(where:Vector2):
	# This function is called when a player enter a new room via a door
	# Called by the door it enterd through, to spawn in the new room
	position = where
	pass

func _ready(): # once node entered tree
	spawn_me(gWorld.spawn_side)
	pass
	
func _physics_process(delta):
	if(not networked):
		_movement(delta)
	#gWorld.WorldState.append()
#	add_player_state()

func _movement(delta):
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
	add_player_state()

func remote_movement(where:Vector2):
	position = where

func add_player_state():
	var player_state = {"T": OS.get_system_time_msecs(), "P": get_global_position()}
	gWorld.add_player_state(player_state)
