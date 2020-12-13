extends Control

onready var background = $AnimatedSprite
export var move_speed = 0.5
var x =  340 #340 - 560
var go_left = false

func _process(_delta):
	if go_left:
		if x >= 345:
			x -= move_speed
		else:
			go_left = false
	else:
		if x <= 555:
			x += move_speed
		else:
			go_left = true
	background.position.x = x
 
func _ready():
	$lVersion.text = Global.version
