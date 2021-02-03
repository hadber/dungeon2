extends Node

func _proccess_state():
	if not get_parent().pStates.empty():
		var worldState = get_parent().pStates.duplicate(true)
		for player in worldState.keys():
			worldState[player].erase("T")
		worldState["T"] = OS.get_system_time_msecs()
		
		get_parent().send_world_state(worldState)
