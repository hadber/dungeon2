extends Node

var types = ["up", "right", "down", "left"]
var sDoors = ["up"]

const Doors = {
	up = { 
		position = Vector2(450, 75),
		rotation = 0
		},
	right = {
		position = Vector2(825, 300),
		rotation = 90
		},
	down = {
		position = Vector2(450, 525),
		rotation =  180
		},
	left = {
		position = Vector2(75, 300),
		rotation = 270
	}
}

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
			

"""
var last_delta = 0
var cur = 0
func _process(delta):
	if (last_delta - delta) > 0.5:
#		print('working!')
		get_node("../door").position = Doors[types[cur]].position
		get_node("../door").rotation_degrees = Doors[types[cur]].rotation
		
		cur = cur + 1 if cur < 3 else 0
		last_delta = delta
	else:
		last_delta += delta
"""
