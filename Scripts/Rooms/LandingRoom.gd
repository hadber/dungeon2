extends "res://Scripts/Rooms/BasicRoomPrototype/BasicRoomPrototype.gd"

func _ready():
	sDoors = ["right"]
	var LobbyRoom = load("res://Scenes/RoomTypes/LobbyRoom.tscn").instance()
	rooms["right"] = LobbyRoom
	LobbyRoom.sDoors = ["left"]
	LobbyRoom.rooms["left"] = self
	LobbyRoom.create_room()
	LobbyRoom.close_doors()
#	LobbyRoom.open_doors()
	create_room()
	gWorld.Player1.spawn_me(gWorld.spawn_side)
