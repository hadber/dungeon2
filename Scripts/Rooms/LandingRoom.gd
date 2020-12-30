extends "res://Scripts/Rooms/BasicRoomPrototype/BasicRoomPrototype.gd"

func _ready():
	sDoors = ["right"]
	var LobbyRoom = load("res://Scenes/RoomTypes/LobbyRoom.tscn").instance()
	rooms["right"] = LobbyRoom
	LobbyRoom.sDoors = ["left"]
	LobbyRoom.rooms["left"] = self
	create_room()
	gWorld.Player1.spawn_me(gWorld.spawn_side)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
