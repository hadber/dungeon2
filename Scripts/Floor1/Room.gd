extends Node

const PlayerScene = preload("res://Scenes/Player.tscn")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var Player1 = PlayerScene.instance()
	Player1.get_node("CenterContainer/Name").text = Steam.getFriendPersonaName(Global.STEAM_ID)
	self.add_child(Player1)
	Global.PLAYERS.append(Player1)

func spawn_new_player(SteamID):
	var Player2 = PlayerScene.instance()
	Player2.get_node("CenterContainer/Name").text = Steam.getFriendPersonaName(SteamID)
	self.add_child(Player2)
	Global.PLAYERS.append(Player2)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
