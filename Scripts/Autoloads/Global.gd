extends Node

var gSteamID:int
var gSteamUsername:String
var lobbyMembers:Array = []
var in_dialogue:bool = false
var steamLobbyID:int = 0
var lobbyMemberNames:Dictionary = {}
var chatNode
var isPlayerHost:bool
var players = {}
var version = 'ver 0.1.5a'

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
	
	Steam.connect("join_requested", self, "_on_lobby_join_requested()")

func _process(_delta):
	Steam.run_callbacks()

func _on_lobby_join_requested(lobbyID:int, friendID:int):
	# triggered if the player is already in game and accepts a steam invite
	# or clicks 'join game' in the friendlist to join a friend's game
	print("Joining %s's lobby" % Steam.getFriendPersonaName(friendID))
	
	
	var _ret = get_tree().change_scene("res://Scenes/RoomTypes/LobbyRoom.tscn") # test scene
	# join the lobby normally
	get_node("MultiplayerLoader/Multiplayer")._join_lobby(lobbyID)
