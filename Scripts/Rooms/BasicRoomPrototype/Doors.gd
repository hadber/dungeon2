extends Node2D

var types = ["up", "right", "down", "left"]
var sDoors = ["up"]


func _ready():
	for tDoor in types:
		var wall = get_node(tDoor)
		var midwall = wall.get_node("mid")
		var door = wall.get_node("door")
		
		if tDoor in sDoors:
			print("is in sDoors:", tDoor)
			door.visible = true
			door.monitoring = true
			midwall.set_deferred("disabled", true)
		else:
			print("is NOT in sDoors:", tDoor)
			door.visible = false
			door.monitoring = false
			midwall.set_deferred("disabled", false)
