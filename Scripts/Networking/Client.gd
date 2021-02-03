extends Node

onready var Multiplayer = get_parent()
var oldStateTime:int = 0
var worldStateBuffer:Array = []
const INTERP_OFFSET = 100

func _process(_delta):
	Multiplayer._send_p2p_packet("host", Multiplayer.SENDTYPES.UNRELIABLE, Multiplayer.PACKETS.PLAYERSTATE, gWorld.PlayerState)

func update_worldstate(newState):
	if newState["T"] > oldStateTime:
		oldStateTime = newState["T"]
		worldStateBuffer.append(newState)

# [most recent past worldstate, nearest future world state, any other future world state]
func _physics_process(_delta):
	var renderTime = OS.get_system_time_msecs() - INTERP_OFFSET
	if worldStateBuffer.size() > 1:
		while worldStateBuffer.size() > 2 and renderTime > worldStateBuffer[1]["T"]:
			worldStateBuffer.remove(0)
		var interpolationFactor = float(renderTime - worldStateBuffer[0]["T"]) / float(worldStateBuffer[1]["T"] - worldStateBuffer[0]["T"])
		for playerID in worldStateBuffer[1].keys():
			if str(playerID) == "T":
				# its the timestamp of the worldstate (one of the dict entries)
				continue
			if playerID == Global.gSteamID:
				# we just found ourselves in the worldstate, we dont care about this!
				continue
			if not worldStateBuffer[0].has(playerID):
				# the player doesnt have a PAST worldstate, we wait a bit until one is generated
				continue
			if(gWorld.currentRoom.get_node("Entities")).has_node(str(playerID)):
				var newPos = lerp(worldStateBuffer[0][playerID]["P"], worldStateBuffer[1][playerID]["P"], interpolationFactor)
				gWorld.currentRoom.get_node("Entities/" + str(playerID)).remote_movement(newPos)
			else:
				gWorld.add_remote_player(str(playerID), worldStateBuffer[1][playerID]["P"])
				
func update_worldstateOLD(newState):
		newState.erase("T")
		newState.erase(Global.gSteamID)
		
		for playerID in newState.keys():
			if(gWorld.currentRoom.get_node("Entities")).has_node(str(playerID)):
				gWorld.currentRoom.get_node("Entities/" + str(playerID)).remote_movement(newState[playerID]["P"])
			else:
				print("spawning player")
				gWorld.Player2.spawn_me(newState[playerID]["P"])
