extends KinematicBody2D

var speed = 400
var velocity = Vector2()

func _draw(): # show the actual movement vector that's happening 
	draw_line(Vector2(0, 0), velocity/5, Color(1.0, 0.2, 0.5), 2.0)
#	print(position, Vector2(position.x + motion.x, position.y + motion.y))

func _process(_delta):
	update()

func _ready():
	position = Vector2(400, 300)

func get_input():
	# Detect up/down/left/right keystate and only move when pressed
	velocity = Vector2()
	velocity.x = Input.get_action_strength("right") - Input.get_action_strength("left") 
	velocity.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	velocity = velocity.normalized() * speed

func _physics_process(delta):
	get_input()
	var remainder = move_and_collide(velocity * delta)
