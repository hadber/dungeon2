extends Node

const PlayerScene = preload("res://Scenes/Player.tscn")
const PlayerNetworkScript = preload("res://Scripts/Entities/Player/PlayerNetwork.gd")

var DATA
var LOBBY_INVITE_ARG = false
var lobby_changed:bool = false
var members_downloaded = 0

signal lobby_members_changed


# Called when the node enters the scene tree for the first time.
func _ready():
	# warning-ignore:return_value_discarded
	$"../Multiplayer".connect("lobby_members_changed", self, "_on_Lobby_members_changed")
	# warning-ignore:return_value_discarded
	Steam.connect("lobby_chat_update", self, "_on_Lobby_Chat_Update")
	# warning-ignore:return_value_discarded
	Steam.connect("avatar_loaded", self, "loaded_avatar")
	# warning-ignore:return_value_discarded
	Steam.connect("lobby_created", self, "_on_Lobby_Created")
	# warning-ignore:return_value_discarded
	Steam.connect("lobby_joined", self, "_on_Lobby_Joined") 
	# warning-ignore:return_value_discarded
#	Steam.connect("lobby_invite", self, "_on_Lobby_Invite")
	# warning-ignore:return_value_discarded
	Steam.connect("p2p_session_request", self, "_on_P2P_Session_Request")
	# warning-ignore:return_value_discarded
	Steam.connect("p2p_session_connect_fail", self, "_on_P2P_Session_Connect_Fail")
	
	Steam.connect("join_requested", self, "_on_Lobby_Join_Requested")
#	Steam.connect("lobby_message", self, "_on_Lobby_Message")
#	Steam.connect("lobby_data_update", self, "_on_Lobby_Data_Update")
	# Check for command line arguments
	_check_Command_Line()
	_create_Lobby()
	
func _process(_delta):
	_read_P2P_Packet()
	
func _check_Command_Line():
	var ARGUMENTS = OS.get_cmdline_args()

	# There are arguments to process
	if ARGUMENTS.size() > 0:

		# Loop through them and get the useful ones
		for ARGUMENT in ARGUMENTS:
			print("Command line: " + str(ARGUMENT))

			# An invite argument was passed
			if LOBBY_INVITE_ARG:
				_join_Lobby(int(ARGUMENT))

			# A Steam connection argument exists
			if ARGUMENT == "+connect_lobby":
				LOBBY_INVITE_ARG = true

func _create_Lobby():
	# Make sure a lobby is not already set
	if Global.STEAM_LOBBY_ID == 0:
		Steam.createLobby(1, 2) 

func _on_Lobby_Created(connect, lobbyID):
	if connect == 1:
		# Set the lobby ID
		Global.STEAM_LOBBY_ID = lobbyID
		print("Created a lobby: "+str(Global.STEAM_LOBBY_ID))
		Global.isPlayerHost = true
		# Set some lobby data
#		Steam.setLobbyData(lobbyID, "name", "Gramps' Lobby")
#		Steam.setLobbyData(lobbyID, "mode", "GodotSteam test")

		# Allow P2P connections to fallback to being relayed through Steam if needed
		var RELAY = Steam.allowP2PPacketRelay(true)
		print("Allowing Steam to be relay backup: "+str(RELAY))

func _join_Lobby(lobbyID):
	print("Attempting to join lobby " + str(lobbyID) + "...")
	
	# Clear any previous lobby members lists, if you were in a previous lobby
	Global.LOBBY_MEMBERS.clear()

	# Make the lobby join request to Steam
	Steam.joinLobby(lobbyID)

func _on_Lobby_Joined(lobbyID, _permissions, _locked, _response):
	
	# Set this lobby ID as your lobby ID
	Global.STEAM_LOBBY_ID = lobbyID
	
	# Get the lobby members
	_get_Lobby_Members()
	Global.ChatNode.add_chat("Joined lobby " + str(lobbyID))
	# Make the initial handshake
	_make_P2P_Handshake()

func _on_Lobby_Join_Requested(lobbyID, friendID):
	
	# Get the lobby owner's name
	var OWNER_NAME = Steam.getFriendPersonaName(friendID)
	print("Joining " + str(OWNER_NAME) + "'s lobby...")
	Global.isPlayerHost = false
	# Attempt to join the lobby
	_join_Lobby(lobbyID)

func _get_Lobby_Members():
	print("getting lobby members")
	# Clear your previous lobby list
	Global.LOBBY_MEMBERS.clear()
	Global.NAMES.clear()

	# Get the number of members from this lobby from Steam
	var MEMBERS = Steam.getNumLobbyMembers(Global.STEAM_LOBBY_ID)
	print(MEMBERS)

	# Get the data of these players from Steam
	for MEMBER in range(0, MEMBERS):

		# Get the member's Steam ID
		var MEMBER_STEAM_ID = Steam.getLobbyMemberByIndex(Global.STEAM_LOBBY_ID, MEMBER)

		# Get the member's Steam name
		var MEMBER_STEAM_NAME = Steam.getFriendPersonaName(MEMBER_STEAM_ID)

		# Add them to the list
		Global.LOBBY_MEMBERS.append({"steam_id":MEMBER_STEAM_ID, "steam_name":MEMBER_STEAM_NAME})
		Global.NAMES[MEMBER_STEAM_ID] = MEMBER_STEAM_NAME
		Steam.getPlayerAvatar(1, MEMBER_STEAM_ID) # [1 - 3], SMALL to LARGE
		
		if MEMBER_STEAM_ID != Global.STEAM_ID:
			var Player2 = PlayerScene.instance()
			Player2.get_node("CenterContainer/Name").text = MEMBER_STEAM_NAME
			Player2.get_node("Sprite").modulate = Color("#0000ff")
			Player2.set_script(PlayerNetworkScript)
			get_parent().add_child(Player2)
			Global.PLAYERS[str(MEMBER_STEAM_ID)] = Player2
		
		# apparently Steam.getSmallFriendAvatar does not seem to work, or at least
		# I'm not entirely sure how it works
		# Needs further testing, but so far it works like this aswell!
		
	lobby_changed = true

func _on_Send_Chat_pressed():

	# Get the entered chat message
	var MESSAGE = $Chat.get_text()

	# Pass the message to Steam
	var SENT = Steam.sendLobbyChatMsg(Global.STEAM_LOBBY_ID, MESSAGE)

	# Was it sent successfully?
	if not SENT:
		print("ERROR: Chat message failed to send.")

	# Clear the chat input
	$Chat.clear()

func _leave_Lobby():

	# If in a lobby, leave it
	if Global.STEAM_LOBBY_ID != 0:

		# Send leave request to Steam
		Steam.leaveLobby(Global.STEAM_LOBBY_ID)

		# Wipe the Steam lobby ID then display the default lobby ID and player list title
		Global.STEAM_LOBBY_ID = 0

		if Global.isPlayerHost:
			var sendVector = PoolByteArray()
			sendVector.append(64)
			sendVector.append_array(var2bytes({"message":"leaveLobbyPlease", "from":Global.STEAM_ID}))
			_send_P2P_Packet(sendVector, 1, 0)

		# Close session with all users
		for MEMBERS in Global.LOBBY_MEMBERS:
			# warning-ignore:return_value_discarded
			Steam.closeP2PSessionWithUser(MEMBERS['steam_id'])
		
		# Clear the local lobby list
		Global.LOBBY_MEMBERS.clear()
		Global.NAMES.clear()

func _on_P2P_Session_Request(remoteID):
	
	# Get the requester's name
	var REQUESTER = Steam.getFriendPersonaName(remoteID)
	
	# Accept the P2P session; can apply logic to deny this request if needed
	if(Global.NAMES.has(remoteID)):
		# warning-ignore:return_value_discarded
		Steam.acceptP2PSessionWithUser(remoteID)
		print("Accepted P2P session with " + str(REQUESTER))
		_make_P2P_Handshake()
	else:
		print("Rejected P2P session with " + str(REQUESTER))

func _make_P2P_Handshake():

	print("Sending P2P handshake to the lobby")
	var lDATA = PoolByteArray()
	lDATA.append(256)
	lDATA.append_array(var2bytes({"message":"handshake", "from":Global.STEAM_ID}))
	_send_P2P_Packet(lDATA, 2, 0)

func _read_P2P_Packet():

	var PACKET_SIZE = Steam.getAvailableP2PPacketSize(0)

	# There is a packet
	if PACKET_SIZE > 0:

		var PACKET = Steam.readP2PPacket(PACKET_SIZE, 0)

		if PACKET.empty():
			print("WARNING: read an empty packet with non-zero size!")

		# Get the remote user's ID
		#var PACKET_ID = str(PACKET.steamIDRemote)
		#var PACKET_CODE = str(PACKET.data[0])

		# Make the packet data readable
		var READABLE = bytes2var(PACKET.data.subarray(1, PACKET_SIZE - 1))

		if READABLE.has("from"):
			if str(READABLE["message"]) == "leaveLobbyPlease":
				_leave_Lobby()
				Global.ChatNode.add_chat("Lobby leader disconnected, abandoning lobby...")
			elif Global.PLAYERS.has(str(READABLE["from"])):
				if str(READABLE["message"]) != "handshake":
					Global.PLAYERS.get(str(READABLE["from"])).update_vector(READABLE["message"])

func _send_P2P_Packet(data, send_type, channel):
	
	if Global.LOBBY_MEMBERS.size() > 1:
	
		for MEMBER in Global.LOBBY_MEMBERS:
			if MEMBER['steam_id'] != Global.STEAM_ID:
				# warning-ignore:return_value_discarded
				Steam.sendP2PPacket(MEMBER['steam_id'], data, send_type, channel)

func _on_Lobby_Chat_Update(_lobbyID, _changedID, makingChangeID, chatState):

	_get_Lobby_Members()

	var CHANGER = Steam.getFriendPersonaName(makingChangeID)
	if chatState == 1:
		print(str(CHANGER) + " has joined the lobby.")
		Global.ChatNode.add_chat(str(CHANGER) + " has joined the game.")

	# Else if a player has left the lobby
	elif chatState == 2:
		print(str(CHANGER) + " has left the lobby.")
		Global.ChatNode.add_chat(str(CHANGER) + " has left the game.")
		remove_player(makingChangeID)
	# Else if a player has been kicked
	elif chatState == 8:
		print(str(CHANGER) + " has been kicked from the lobby.")
		Global.ChatNode.add_chat(str(CHANGER) + " has been kicked from the lobby.")
		remove_player(makingChangeID)
	# Else if a player has been banned
	elif chatState == 16:
		print(str(CHANGER)+" has been banned from the lobby.")
		Global.ChatNode.add_chat(str(CHANGER) + " has been banned from the lobby.")
		remove_player(makingChangeID)
	# Else there was some unknown change
	else:
		print(str(CHANGER)+" did... something.")
		Global.ChatNode.add_chat("Unknown lobby change occured for " + str(CHANGER))

func remove_player(playerID):
	if Global.PLAYERS.has(str(playerID)):
		Global.PLAYERS.get(str(playerID)).queue_free()
		Global.PLAYERS.erase(str(playerID))

func _on_P2P_Session_Connect_Fail(lobbyID, session_error):

	Global.ChatNode.add_chat("P2P session connection failed, check the log for more info.")
	# If no error was given
	if session_error == 0:
		print("WARNING: Session failure with " + str(lobbyID) + " [no error given].")

	# Else if target user was not running the same game
	elif session_error == 1:
		print("WARNING: Session failure with " + str(lobbyID) + " [target user not running the same game].")

	# Else if local user doesn't own app / game
	elif session_error == 2:
		print("WARNING: Session failure with " + str(lobbyID) + " [local user doesn't own app / game].")

	# Else if target user isn't connected to Steam
	elif session_error == 3:
		print("WARNING: Session failure with " + str(lobbyID) + " [target user isn't connected to Steam].")

	# Else if connection timed out
	elif session_error == 4:
		print("WARNING: Session failure with " + str(lobbyID) + " [connection timed out].")

	# Else if unused
	elif session_error == 5:
		print("WARNING: Session failure with " + str(lobbyID) + " [unused].")

	# Else no known error
	else:
		print("WARNING: Session failure with " + str(lobbyID) + " [unknown error " + str(session_error) + "].")

func loaded_avatar(id, size, buffer):

	var AVATAR = Image.new()
	var AVATAR_TEXTURE = ImageTexture.new()
	AVATAR.create(size, size, false, Image.FORMAT_RGBAF)

	AVATAR.lock()
	for y in range(0, size):
		for x in range(0, size):
			var pixel = 4 * (x + y * size)
			var r = float(buffer[pixel]) / 255
			var g = float(buffer[pixel+1]) / 255
			var b = float(buffer[pixel+2]) / 255
			var a = float(buffer[pixel+3]) / 255
			AVATAR.set_pixel(x, y, Color(r, g, b, a)) 
	AVATAR.unlock()

	AVATAR_TEXTURE.create_from_image(AVATAR)
	
	for MEMBER in Global.LOBBY_MEMBERS:
		if MEMBER['steam_id'] == id:
			MEMBER['avatar'] = AVATAR_TEXTURE
	
	# just to be safe in the future, we don't know if we'll need the avatar for other
	# things in the networking side and we don't want to update it every time we get a new
	# avatar
	members_downloaded += 1
	if lobby_changed && members_downloaded == len(Global.LOBBY_MEMBERS):
		members_downloaded = 0
		lobby_changed = false
		emit_signal("lobby_members_changed")

func _on_Lobby_members_changed():
	pass

func _exit_tree():
	_leave_Lobby()
