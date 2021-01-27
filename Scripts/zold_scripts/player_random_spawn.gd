extends Node2D

func _ready(): # once node entered tree
	randomize()
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var randx = rng.randf_range(150.0, 750.0)
	var randy = rng.randf_range(125.0, 450.0)
	print("random start: (" + str(randx) + "," + str(randy) + ")")
	position = Vector2(randx, randy)
