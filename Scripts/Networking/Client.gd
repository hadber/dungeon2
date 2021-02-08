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

# [older past worldstate (extrapolation), most recent past worldstate, nearest future world state, any other future world state]
func _physics_process(_delta):
	var renderTime = OS.get_system_time_msecs() - INTERP_OFFSET
	if worldStateBuffer.size() > 1:
		while worldStateBuffer.size() > 2 and renderTime > worldStateBuffer[2]["T"]:
			worldStateBuffer.remove(0)
		if worldStateBuffer.size() > 2:
			var interpolationFactor = float(renderTime - worldStateBuffer[1]["T"]) / float(worldStateBuffer[2]["T"] - worldStateBuffer[1]["T"])
			for playerID in worldStateBuffer[2].keys():
				if str(playerID) == "T":
					# its the timestamp of the worldstate (one of the dict entries)
					continue
				if playerID == Global.gSteamID:
					# we just found ourselves in the worldstate, we dont care about this!
					continue
				if not worldStateBuffer[1].has(playerID):
					# the player doesnt have a PAST worldstate, we wait a bit until one is generated
					continue
				if(gWorld.currentRoom.get_node("Entities")).has_node(str(playerID)):
					var newPos:Vector2 = lerp(worldStateBuffer[1][playerID]["P"], worldStateBuffer[2][playerID]["P"], interpolationFactor)
		#			print(worldStateBuffer[0][playerID]["P"], worldStateBuffer[1][playerID]["P"], interpolationFactor, newPos, renderTime)
					gWorld.currentRoom.get_node("Entities/" + str(playerID)).remote_movement(newPos)
				else:
					gWorld.add_remote_player(str(playerID), worldStateBuffer[2][playerID]["P"])
		elif renderTime > worldStateBuffer[1].T:
			var extrapolationFactor = float(renderTime - worldStateBuffer[0]["T"]) / float(worldStateBuffer[1]["T"] - worldStateBuffer[0]["T"]) - 1.0
			for playerID in worldStateBuffer[1].keys():
				if str(playerID) == "T":
					continue
				if playerID == Global.gSteamID:
					continue
				if not worldStateBuffer[1].has(playerID):
					continue
				if(gWorld.currentRoom.get_node("Entities")).has_node(str(playerID)):
					var positionDelta = worldStateBuffer[1][playerID]["P"] - worldStateBuffer[0][playerID]["P"]
					var newPos:Vector2 = worldStateBuffer[1][playerID]["P"] + (positionDelta * extrapolationFactor)
					gWorld.currentRoom.get_node("Entities/" + str(playerID)).remote_movement(newPos)
			
func update_worldstateOLD(newState):
		newState.erase("T")
		newState.erase(Global.gSteamID)
		
		for playerID in newState.keys():
			if(gWorld.currentRoom.get_node("Entities")).has_node(str(playerID)):
				gWorld.currentRoom.get_node("Entities/" + str(playerID)).remote_movement(newState[playerID]["P"])
			else:
				print("spawning player")
				gWorld.Player2.spawn_me(newState[playerID]["P"])
