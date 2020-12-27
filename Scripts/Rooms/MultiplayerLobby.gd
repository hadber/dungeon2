extends Node2D

const PlayerScene = preload("res://Scenes/Player.tscn")
const DoorScene = preload("res://Scenes/Door.tscn")

const types = ["up", "right", "down", "left"]
var sDoors = ["up", "right"]

func _ready():
	var Player1 = PlayerScene.instance()
	Player1.get_node("CenterContainer/Name").text = Steam.getFriendPersonaName(Global.STEAM_ID)
	self.add_child_below_node($Doors, Player1)
	
	for tDoor in types:
		var wall = $Walls.get_node(tDoor)
		var midwall = wall.get_node("mid")
		
		if tDoor in sDoors:
			print("is in sDoors:", tDoor)
			var a_door = DoorScene.instance()
			a_door.spawn(tDoor)
			$Doors.add_child(a_door)
			a_door.connect("player_entered", self, "on_player_entered_door")
			
			midwall.set_deferred("disabled", true)
			
		else:
			print("is NOT in sDoors:", tDoor)
			midwall.set_deferred("disabled", false)

func on_player_entered_door(which_side):
	print(which_side)
