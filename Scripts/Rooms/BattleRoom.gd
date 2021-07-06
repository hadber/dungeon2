extends "res://Scripts/Rooms/BasicRoomPrototype/BasicRoomPrototype.gd"

func _ready():
	var Slime = load("res://Scenes/Entities/Slime.tscn").instance()
	$Entities.add_child(Slime)
	Slime.spawn()
