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
	Global.PLAYERS["host"] = Player1

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
