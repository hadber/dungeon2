extends KinematicBody2D

var health:float
var is_networked


func _ready():
	pass 
	
func move():
	pass

func take_damage(amount:float):
	health -= amount

func spawn():
	pass

func add_worldstate():
	pass
