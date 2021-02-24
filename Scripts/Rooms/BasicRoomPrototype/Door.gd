extends StaticBody2D

var my_side = ""
var open_png = preload("res://Assets/RoomAssets/door.png")
var closed_png = preload("res://Assets/RoomAssets/door_closed.png")


signal player_entered(where)

const doors_pos = {
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
	var _area_sig_ret = $area.connect("body_entered", self, "_on_body_entered")

func spawn(where):
	self.position = doors_pos[where].position
	self.rotation_degrees = doors_pos[where].rotation
	self.my_side = where

func _on_body_entered(body):
	if(body.is_in_group("player")):
		emit_signal("player_entered", my_side)

func close_me():
	$door_sprite.texture = closed_png

func open_me():
	$door_sprite.texture = open_png
