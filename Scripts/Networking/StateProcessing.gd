extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _proccess_state():
	if not get_parent().pStates.empty():
		var worldState = get_parent().pStates.duplicate(true)
		for player in worldState.keys():
			worldState[player].erase("T")
		worldState["T"] = OS.get_system_time_msecs()
		
		get_parent().send_world_state(worldState)
