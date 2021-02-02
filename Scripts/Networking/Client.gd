extends Node

onready var Multiplayer = get_parent()
var oldState = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(_delta):
	Multiplayer._send_p2p_packet("host", Multiplayer.SENDTYPES.UNRELIABLE, Multiplayer.PACKETS.PLAYERSTATE, gWorld.PlayerState)

func update_worldstate(newState):
	if newState["T"] > oldState:
		oldState = newState["T"]
		newState.erase("T")
		newState.erase(Global.gSteamID)
		
		for playerID in newState.keys():
			if(gWorld.currentRoom.get_node("Entities")).has_node(str(playerID)):
				gWorld.currentRoom.get_node("Entities/" + str(playerID)).remote_movement(newState[playerID]["P"])
			else:
				print("spawning player")
				gWorld.Player2.spawn_me(newState[playerID]["P"])
#	for entry in worldstate:
