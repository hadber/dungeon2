extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func _input(event):
	if event.is_action_pressed("show_playerlist"):
		self.visible = true
	elif event.is_action_released("show_playerlist"):
		self.visible = false
# Called when the node enters the scene tree for the first time.
func _ready():
	# initially set this to invisible
	self.visible = false
	# connect it to the signal so that only when there are changes to the lobby
	# members (eg someone leaves or joins), the list is updated
	$"../Networking".connect("lobby_members_changed", self, "_on_Lobby_members_changed")

func _on_Lobby_members_changed(): # triggered when someones leaves/joins the lobby
	
	# free the previous list (remove members that might've left)
	for child in $VBoxContainer/Users.get_children(): 
		child.queue_free()
	
	# recreate the list
	for MEMBER in Global.LOBBY_MEMBERS:
		var avatar = TextureRect.new()
		var steam_name =  Label.new()
		var separator = VSeparator.new()
		var container = HBoxContainer.new()
		
		avatar.texture = MEMBER['avatar']
		steam_name.text = MEMBER['steam_name']
		
		container.add_child(avatar)
		container.add_child(separator)
		container.add_child(steam_name)
		
		# add it as child of control node Users
		# the node serves no purpose other than making it 
		# easier to free (all of its children are users)
		$VBoxContainer/Users.add_child(container)
