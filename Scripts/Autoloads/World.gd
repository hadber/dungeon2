extends Node2D

# gWorld
const PlayerScene = preload("res://Scenes/Player.tscn")
var Player1
var spawn_side:Vector2 = Vector2(450, 260)
var WorldState = []


func _ready():
	Player1 = PlayerScene.instance()
	Player1.get_node("CenterContainer/Name").text = Steam.getFriendPersonaName(Global.STEAM_ID)
