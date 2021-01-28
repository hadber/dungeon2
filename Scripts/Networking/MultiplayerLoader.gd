extends Node

const mp_scene = preload("res://Scenes/Multiplayer.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	if(Global.isPlayerHost == true):
		add_multiplayer_scene(true)

func add_multiplayer_scene(createLobby:bool = false): # we dont create a lobby in this case
	var actualMP = mp_scene.instance()
	if(createLobby):
		actualMP._create_lobby()
	else:
		actualMP.spawn_guest_player() # this 
	add_child(actualMP)
