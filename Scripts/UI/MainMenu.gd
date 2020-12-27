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
	$MarginContainer/CenterContainer/VBoxContainer/CenterContainer/VBoxContainer/btPlay.connect("pressed", self, "_btOnPlayPressed")
	# warning-ignore:return_value_discarded
	$MarginContainer/CenterContainer/VBoxContainer/CenterContainer/VBoxContainer/btOptions.connect("pressed", self, "_btOnOptionsPressed")
	# warning-ignore:return_value_discarded
	$MarginContainer/CenterContainer/VBoxContainer/CenterContainer/VBoxContainer/btQuit.connect("pressed", self, "_btOnQuitPressed")
	
	$lVersion.text = Global.version

func _btOnPlayPressed():
	print("Start the game (go to the main area)")
	# warning-ignore:return_value_discarded
	var ret = get_tree().change_scene("res://Scenes/Room.tscn") # test scene
	if(ret == OK):
		print('test')
	
func _btOnOptionsPressed():
	print("No options at the moment :( (sorry!)")

func _btOnQuitPressed():
	print("Goodbye!")
	get_tree().quit()