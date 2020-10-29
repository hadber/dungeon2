extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# to not accidentaly click chat, allow it only to be enabled by pressing enter

func _input(event):

	if event.is_action_pressed("enter"): 
		#print("pressed enter")
		if Global.in_dialogue: # if he presses enter while already in dialogue
			end_dialogue() # end the dialogue, send it all and clear
			Steam.sendLobbyChatMsg(Global.STEAM_LOBBY_ID, $Input.text)
			$Chat.add_text(Global.STEAM_USERNAME + ": " + $Input.text + "\n")
			#clear char and send
			$Input.clear()
		else:
			start_dialogue() # else, start a dialogue
			
	elif event.is_action_pressed("escape"): # end dialogue
		#print("pressed escape")
		end_dialogue()
		
func start_dialogue():
	Global.in_dialogue = true
	$Input.grab_focus()
	
func end_dialogue():
	Global.in_dialogue = false
	$Input.release_focus()

func _on_Lobby_Message(_result, user, buffer, _chattype):
	# if it's the current user, no need to send the message
	# as we've already sent it locally
	if(user != Global.STEAM_ID):
		$Chat.add_text(Global.NAMES.get(user) + ": " + buffer + "\n")

func _ready():
	Steam.connect("lobby_message", self, "_on_Lobby_Message")
	pass

