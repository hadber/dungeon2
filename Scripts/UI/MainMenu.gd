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
	# warning-ignore:return_value_discarded
	$MarginContainer/CenterContainer/VBoxContainer/CenterContainer/VBoxContainer/btPlay.connect("pressed", self, "_btPlayOnPressed")
	# warning-ignore:return_value_discarded
	$MarginContainer/CenterContainer/VBoxContainer/CenterContainer/VBoxContainer/btOptions.connect("pressed", self, "_btOptionsOnPressed")
	# warning-ignore:return_value_discarded
	$MarginContainer/CenterContainer/VBoxContainer/CenterContainer/VBoxContainer/btQuit.connect("pressed", self, "_btQuitOnPressed")
	
	$lVersion.text = Global.version

func _btPlayOnPressed():
	# warning-ignore:return_value_discarded
	var ret = get_tree().change_scene("res://Scenes/RoomTypes/LandingRoom.tscn") # test scene
#	gWorld.spawn_player(Vector2(450, 450))
	if(ret == OK):
		print("Changing scenes worked, we're now in the main area")
	
func _btOptionsOnPressed():
	print("No options at the moment :( (sorry!)")

func _btQuitOnPressed():
	print("Goodbye!")
	get_tree().quit()
