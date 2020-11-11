extends Node

#var ONLINE = Steam.loggedOn()
var STEAM_ID
var STEAM_USERNAME
var LOBBY_MEMBERS = []
var in_dialogue = false
var STEAM_LOBBY_ID = 0
var NAMES = {}
var ChatNode
var isPlayerHost:bool
var PLAYERS = {}
#var OWNED = Steam.isSubscribed()

func _ready():

	var INIT = Steam.steamInit()
	print("Steam init: " + str(INIT))
		
	STEAM_ID = Steam.getSteamID()
	STEAM_USERNAME = Steam.getFriendPersonaName(STEAM_ID)
	
	if INIT['status'] != 1:
		print("Failed to initialize Steam. " + str(INIT['verbal']) + " Shutting down...")
		get_tree().quit()

func _process(_delta):
	Steam.run_callbacks()
