extends Node

const mp_scene = preload("res://Scenes/Multiplayer.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	if(Global.isPlayerHost == true):
		var actual_mp = mp_scene.instance()
		actual_mp._create_lobby()
		add_child(actual_mp)

func create_mp(): # we dont create a lobby in this case
	var actual_mp = mp_scene.instance()
	add_child(actual_mp)
