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

func _process(_delta):
	Steam.run_callbacks()
