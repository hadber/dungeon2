extends Node2D

const DoorScene = preload("res://Scenes/BasicRoom/Door.tscn")

const types = ["up", "right", "down", "left"]
var sDoors = []

const spawn_sides = {
	up =  Vector2(450, 450),
	right = Vector2(150, 300),
	down = Vector2(450, 150),
	left =  Vector2(750, 300)
}

var rooms = { # populate with rooms further down the line
	up = null,
	right = null,
	down = null,
	left = null
} 

func _enter_tree():
	add_child_below_node($Doors, gWorld.Player1)
	gWorld.Player1.spawn_me(gWorld.spawn_side)

func _ready():
	create_room()

func create_room():
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
	remove_child(gWorld.Player1)
	
	var root = get_tree().get_root()
	# Remove the current room from the scene tree
	root.call_deferred("remove_child", self) 
	# Change to the new room
	root.call_deferred("add_child", rooms[which_side])
	gWorld.spawn_side = spawn_sides[which_side]
#	var _ret = get_tree().change_scene_to(rooms[which_side]) # test scene
	
#	if _ret != OK:
#		print("Couldn't change rooms for some reason...")
