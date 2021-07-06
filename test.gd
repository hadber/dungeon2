extends "res://Scripts/Entities/Player/Player.gd"

onready var _parent = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	_parent.move_and_slide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
