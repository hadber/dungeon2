extends Control

onready var Multiplayer = get_parent()

func _unhandled_input(event):
	if event.is_action_pressed("show_playerlist"):
		self.visible = true
	elif event.is_action_released("show_playerlist"):
		self.visible = false

func _ready():
	# initially set this to invisible
	self.visible = false
	
	# Clean up the example ones, leave them in the editor so you can see
	# what they look like without having to get in game
	$"VBoxContainer/Users/HBoxContainer/Label".queue_free()
	$"VBoxContainer/Users/HBoxContainer/VSeparator".queue_free()
	$"VBoxContainer/Users/HBoxContainer/TextureRect".queue_free()
	
	# connect it to the signal so that only when there are changes to the lobby
	# members (eg someone leaves or joins), the list is updated
	Multiplayer.connect("playerlist_update", self, "_on_playerlist_update")

func _on_playerlist_update(): # triggered when someones leaves/joins the lobby
	
	# free the previous list (remove members that might've left)
	for child in $VBoxContainer/Users.get_children(): 
		child.queue_free()
	
	# recreate the list
	for member in Multiplayer.lobbyMembers:
		var pAvatar = TextureRect.new()
		var pName =  Label.new()
		var separator = VSeparator.new()
		var container = HBoxContainer.new()
		
		pAvatar.texture = member['avatar']
		pName.text = member['steam_name']
		
		container.add_child(pAvatar)
		container.add_child(separator)
		container.add_child(pName)
		
		# add it as child of control node Users
		# the node serves no purpose other than making it 
		# easier to free (all of its children are users)
		$VBoxContainer/Users.add_child(container)
