extends Node

const mp_scene = preload("res://Scenes/Multiplayer.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	if(Global.isPlayerHost == true):
		create_mp()

func create_mp():
	var actual_mp = mp_scene.instance()
	actual_mp._create_lobby()
	add_child(actual_mp)
