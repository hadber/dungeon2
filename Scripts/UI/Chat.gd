extends Control

onready var Multiplayer = get_parent()
var pNames = {}

# to not accidentaly click chat, allow it only to be enabled by pressing enter
func _ready():
	# warning-ignore:return_value_discarded
	Steam.connect("lobby_message", self, "_on_lobby_message")
	add_chat(">> Press enter to chat")
	
	Multiplayer.connect("playerlist_update", self, "_on_playerlist_update")

func _input(event):
	if event.is_action_pressed("enter"): 
		if Global.in_dialogue: # if he presses enter while already in dialogue
			end_dialogue() # end the dialogue, send it all and clear
			
			#clear chat and send
			if($Input.text.strip_edges() != ""):
				# warning-ignore:return_value_discarded
				Steam.sendLobbyChatMsg(Global.steamLobbyID, $Input.text)
				$Chat.add_text(Global.gSteamUsername + ": " + $Input.text + "\n")
				$Input.clear()
		else:
			start_dialogue() # else, start a dialogue
			
	elif event.is_action_pressed("escape"): # end dialogue
		end_dialogue()

func start_dialogue():
	Global.in_dialogue = true
	$Input.grab_focus()

func end_dialogue():
	Global.in_dialogue = false
	$Input.release_focus()

func _on_lobby_message(_result, user, buffer, _chattype):
	# if it's the current user, no need to send the message
	# as we've already sent it locally
	if(user != Global.gSteamID):
		if(pNames.has(user)):
			$Chat.add_text(pNames.get(user) + ": " + buffer + "\n")

func add_chat(text):
	$Chat.add_text(text + "\n")

func _on_playerlist_update():
	for member in Multiplayer.lobbyMembers:
		pNames[member.steam_id] = member.steam_name
