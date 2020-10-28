extends Node

#var ONLINE = Steam.loggedOn()
var STEAM_ID = Steam.getSteamID()
var STEAM_USERNAME = Steam.getPersonaName()
var LOBBY_MEMBERS = []
#var OWNED = Steam.isSubscribed()

func _ready():

	var INIT = Steam.steamInit()
	print("Steam init: " + str(INIT))
		
	if INIT['status'] != 1:
		print("Failed to initialize Steam. " + str(INIT['verbal']) + " Shutting down...")
		get_tree().quit()

func _process(_delta):
	Steam.run_callbacks()
