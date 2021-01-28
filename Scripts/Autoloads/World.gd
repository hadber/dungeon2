extends Node2D

# gWorld
const PlayerScene = preload("res://Scenes/Player.tscn")
var Player1
var spawn_side:Vector2 = Vector2(450, 260)
var WorldState = []
var Player2
var currentRoom

func _ready():
	Player1 = PlayerScene.instance()
	Player1.get_node("CenterContainer/Name").text = Steam.getFriendPersonaName(Global.gSteamID)

func add_player_two(pSteamID:String):
	Player2 = PlayerScene.instance()
	Player2.get_node("CenterContainer/Name").text = Steam.getFriendPersonaName(int(pSteamID))
