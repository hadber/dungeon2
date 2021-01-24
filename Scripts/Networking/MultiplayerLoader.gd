extends Node

const mp_scene = preload("res://Scenes/Multiplayer.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(mp_scene.instance())
