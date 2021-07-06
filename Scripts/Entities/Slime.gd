extends "Entity.gd"

const SPEED = 260
const ACCELERATION = 1600
var velocity = Vector2()

func _ready():
	$Area2D.connect("body_entered", self, "on_Area2D_Body_Entered")
	
	spawn()
	
func _physics_process(delta):
	follow_player(delta)

func spawn():
	#Vector2(randf() * 200 + 100, randf() * 200 + 100)
	position = Vector2(250, 300)
	print("I think I spawned....")

func follow_player(delta):
	var playerPos = gWorld.Player1.position
	velocity = velocity.move_toward((playerPos - position).normalized() * SPEED, ACCELERATION * delta)
	velocity = move_and_slide(velocity)

func on_Area2D_Body_Entered(body: Node):
	if(body == gWorld.Player1):
		body.take_damage(10)
		print("damaged body for 10")
