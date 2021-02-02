extends Node2D

# gWorld
const PlayerScene = preload("res://Scenes/Player.tscn")
var Player1
var spawn_side:Vector2 = Vector2(450, 260)
var last_world_state = 0
var PlayerState:Dictionary = {}
var Player2
var currentRoom
var mpNode = null

func _ready():
	Player1 = PlayerScene.instance()
	Player1.get_node("CenterContainer/Name").text = Steam.getFriendPersonaName(Global.gSteamID)

#func _process(_delta): # send the worldstate to all
	#if(Global.isPlayerHost and mpNode != null): # in this case, send the worldstate to everyone (except maybe yourself?)
	#	mpNode._send_p2p_packet("all", mpNode.SENDTYPES.UNRELIABLE, mpNode.PACKETS.WORLDSTATE, WorldState)
	#elif(mpNode != null):
	#	mpNode._send_p2p_packet("host", mpNode.SENDTYPES.UNRELIABLE, mpNode.PACKETS.WORLDSTATE, WorldState)

func add_player_two(pSteamID:String, pPos:Vector2):
	Player2 = PlayerScene.instance()
	Player2.networked = true
	Player2.get_node("CenterContainer/Name").text = Steam.getFriendPersonaName(int(pSteamID))
	Player2.name = pSteamID
	
	Player2.spawn_me(pPos)
	currentRoom.get_node("Entities").add_child(gWorld.Player2)

func add_player_state(pState:Dictionary):
	PlayerState = pState
