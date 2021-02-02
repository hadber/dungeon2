extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var Multiplayer = get_parent()
onready var Client = get_parent().get_node("Client")

var pStates = {}
var tickRate:int = 20 # 20 times per second

# Called when the node enters the scene tree for the first time.
func _ready():
	$ProcessingTimer.start(1.0 / tickRate)

func send_world_state(worldState:Dictionary):
	Multiplayer._send_p2p_packet("all", Multiplayer.SENDTYPES.UNRELIABLE, Multiplayer.PACKETS.WORLDSTATE, worldState)
	
func update_remote_playerstate(recievedState:Dictionary, playerID:int):
	if(pStates.has(playerID)):
		if pStates[playerID]["T"] < recievedState["T"]:
			# in case the playerstate we've recieved is older than the playerstate that we already have
			pStates[playerID] = recievedState
	else:
		pStates[playerID] = recievedState
#	for player in gWorld.currentRoom.get_node("Entities"):
#		if player.name == str(playerID):
#			player.position = Vector2(pState.P.x, pState.P.y)
	
