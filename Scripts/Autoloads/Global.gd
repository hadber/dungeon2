extends Node

var gSteamID:int
var gSteamUsername:String
var lobbyMembers:Array = []
var in_dialogue:bool = false
var steamLobbyID:int = 0
var lobbyMemberNames:Dictionary = {}
var chatNode
var isPlayerHost:bool = true
var players = {}
var version = 'ver 0.1.5a'

const lobby_room = preload("res://Scenes/RoomTypes/LobbyRoom.tscn")

func _ready():

	var SteamInit = Steam.steamInit()
	print("Steam init: " + str(SteamInit))
		
	gSteamID = Steam.getSteamID()
	gSteamUsername = Steam.getFriendPersonaName(gSteamID)
	
	if SteamInit['status'] != 1:
		print("Failed to initialize Steam. Reason: " + str(SteamInit['verbal']))
	else:
		if Steam.isSubscribed() == false: #game is not owned
			print("Player might have the game pirated, do something here")
	
	Steam.connect("join_requested", self, "_on_lobby_join_requested")
	
	#just for test

func _process(_delta):
	Steam.run_callbacks()

func _on_lobby_join_requested(lobbyID:int, friendID:int):
	# triggered if the player is already in game and accepts a steam invite
	# or clicks 'join game' in the friendlist to join a friend's game
	print("Joining %s's lobby" % Steam.getFriendPersonaName(friendID))
	isPlayerHost = false
	
	var _ret = get_tree().change_scene_to(lobby_room) # test scene
	# join the lobby normally
#	var mp_node = null
#	while(mp_node == null):
	yield(get_tree().create_timer(1.0), "timeout")
	var mp_loader = get_tree().root.get_node("LobbyRoom/MultiplayerLoader")
	mp_loader.add_multiplayer_scene(false)
	var mp_node = get_tree().root.get_node("LobbyRoom/MultiplayerLoader/Multiplayer")
	mp_node._join_lobby(lobbyID)
	# generate the random spawn
	
