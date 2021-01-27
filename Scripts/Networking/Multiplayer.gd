extends Node

func _ready() -> void:
	Steam.connect("lobby_created", self, "_on_lobby_created")
	Steam.connect("lobby_joined", self, "_on_lobby_joined")
	Steam.connect("lobby_chat_update", self, "_on_lobby_chat_update")
#	Steam.connect("lobby_message", self, "_on_Lobby_Message") # a chat message has been sent
#	Steam.connect("lobby_data_update", self, "_on_Lobby_Data_Update") # the lobby metadata has changed
#	Steam.connect("lobby_invite", self, "_on_Lobby_Invite") # get invited to lobby (steam UI takes care of it)
	Steam.connect("p2p_session_request", self, "_on_p2p_session_request")
	Steam.connect("p2p_session_connect_fail", self, "_on_p2p_session_connect_fail")
	
	_check_command_line()

func _check_command_line(): 
	# checks for command line arguments
	# example: when you click "join lobby" in the steam friendslist
	# it will launch the game with the command line argument "+connect_lobby lobbyid"
	# we need to catch that case and process it 
	var args = OS.get_cmdline_args()
	var argLobbyInv:bool = false
	
	if args.size() > 0: # there are arguments to process
		for arg in args:
			print("cmdline arg: " + str(arg))
			
			if argLobbyInv:
				_join_lobby(int(arg))
			
			if arg == "+connect_lobby":
				argLobbyInv = true

func _process(_delta):
	var packet = Steam.getAvailableP2PPacketSize(0)
	
	for pack in packet:
		_read_p2p_packet()

func _create_lobby():
	if Global.steamLobbyID == 0:
		Steam.createLobby(1, 2)
	else: 
		print("ERROR: Failed to create lobby. Lobby already exists (ID: ", Global.steamLobbyID, ")")

func _on_lobby_created(connect: int, lobbyID: int):
	
	if connect == 1: # k_EResultOK - The lobby was successfully created.
		print("SUCCESS: The lobby was successfully created. (ID: ", lobbyID ,")")
		Global.steamLobbyID = lobbyID
		
		#Setting lobby data
		Steam.setLobbyData(lobbyID, "title", "Meta Dungeon (%s) test lobby" % Global.version)
		
		var allowRelay = Steam.allowP2PPacketRelay(true)
		print("Allowing P2P packet relay: " + str(allowRelay))
		
	elif connect == 2: # k_EResultFail - The server responded, but with an unknown internal error.
		print("ERROR: The server responded, but with an unknown internal error.")
	elif connect == 16: # k_EResultTimeout - The message was sent to the Steam servers, but it didn't respond.
		print("ERROR: The message was sent to the Steam servers, but it didn't respond.")
	elif connect == 25: # k_EResultLimitExceeded - Your game client has created too many lobbies and is being rate limited.
		print("ERROR: Your game client has created too many lobbies and is being rate limited.")
	elif connect == 15: # k_EResultAccessDenied - Your game isn't set to allow lobbies, or your client does haven't rights to play the game
		print("ERROR: Your game isn't set to allow lobbies, or your client does haven't rights to play the game")
	elif connect == 3: # k_EResultNoConnection - Your Steam client doesn't have a connection to the back-end.
		print("ERROR: Your Steam client doesn't have a connection to the back-end.")

func _join_lobby(lobbyID:int):
	print("Joining lobby " + str(lobbyID))
	
	# just in case, clear previous members list
	# if it just so happens this is not your first lobby
	Global.lobbyMembers.clear()
	
	# request to join the lobby
	# calls _on_lobby_joined() on success
	Steam.joinLobby(lobbyID)

func _leave_lobby():
	if Global.steamLobbyID != 0: # player is currently in a lobby
		
		Steam.leaveLobby(Global.steamLobbyID)
		Global.steamLobbyID = 0
		
		for member in Global.lobbyMembers:
			Steam.closeP2PSessionWithUser(member['steam_id'])
		
		Global.lobbyMembers.clear()
	else: # player is not part of any lobby - how did we get to this point?
		print("What are you trying to do? You are not part of any lobby! (perhaps an error occured?)")

func _on_lobby_joined(lobbyID:int, _permissions:int, _locked:bool, _response:int):
	if _response == 1: # k_EChatRoomEnterResponseSuccess - the lobby was successfully joined
		print("Successfully joined lobby (ID: %s)" % str(lobbyID)) 
		Global.steamLobbyID = lobbyID
		_get_lobby_members()
		_make_p2p_handshake()
		
	elif _response == 5: # k_EChatRoomEnterResponseError - the lobby join was unsuccesful
		print("Failed joining lobby")

func _get_lobby_members():
	# clear the lobby members, we're in a new lobby now
	Global.lobbyMembers.clear()
	
	# get the number of lobby members
	var totalMembers:int = Steam.getNumLobbyMembers(Global.steamLobbyID)
	
	# get the data on each of the members
	for member in range(0, totalMembers):
		# get their steam ID
		var memberSteamID:int = Steam.getLobbyMemberByIndex(Global.steamLobbyID, member)
		# get their steam name
		var memberSteamName:String = Steam.getFriendPersonaName(memberSteamID)
		# append them to the lobby members array
		Global.lobbyMembers.append({"steam_id": memberSteamID, "steam_name": memberSteamName})

func _make_p2p_handshake():
	print("Sending a p2p handshake request to the lobby...")
	_send_p2p_packet("all", {"message":"handshake", "from":Global.gSteamID}) # needs a bit of fixing later

func _read_p2p_packet():
	var packetSize:int = Steam.getAvailableP2PPacketSize(0)
	
	if packetSize > 0:
		
		# read the packet
		var packet:Dictionary = Steam.readP2PPacket(packetSize, 0)
		
		# it shouldn't be empty if the size is nonzero!
		if packet.empty():
			print("EPIC FAIL: read an empty packet with non-zero size.")
		
		# remote sender information
		var _senderID:String = str(packet.steamIDRemote)
		var _packetCode:String = str(packet.data[0])
		
		print("entire packet: ", packet)
		print("packet data: ", packet.data)
		print("packet code: ", _packetCode)
		var packetRead:PoolByteArray = bytes2var(packet.data.subarray(1, packetSize-1))
		print("Read packet data: ", str(packetRead))

func _send_p2p_packet(target:String, sendDict):
	# send types
	# 0 - unreliable, basic UDP send
	# 1 - unreliable no delay, drop packets if no connection exists
	# 2 - reliable message send, up to 1MB in a single message
	# 3 - reliable with buffering (nagle algorithm)
	
	var sendType = 2
	
	var data:PoolByteArray = PoolByteArray()
	data.append(256)
	data.append_array(var2bytes(sendDict))
	
	if target == "all": # broadcast to all members
		if Global.lobbyMembers.size() > 1:
			for member in Global.lobbyMembers:
				if member['steam_id'] != Global.gSteamID:
					Steam.sendP2PPacket(member['steam_id'], data, sendType, 0)
	else:
		Steam.sendP2PPacket(int(target), data, sendType, 0)
	

func _on_lobby_chat_update(_lobbyID:int, _changedID:int, makingChangeID:int, chatState:int):
	var changerName:String = Steam.getFriendPersonaName(makingChangeID)
	
	if chatState == 1: # player has joined the lobby
		print(changerName, " has joined the lobby.")
	elif chatState == 2: # player has left the lobby
		print(changerName, " has left the lobby.")
	elif chatState == 8: # player has been kicked? - tbh this isnt even implemented in the steamworks backend
		print(changerName, " has been kicked from the lobby.")
	elif chatState == 16: # player has been banned
		print(changerName, " has been banned from the lobby.")
	else: # unknown thing happened to player
		print("Unknown change has occured for ", changerName)
	
	_get_lobby_members() # get the lobby members again since one of them has left.

func _on_p2p_session_request(remoteID:int):
	# name of player requesting peer to peer session
	var _remoteName:String = Steam.getFriendPersonaName(remoteID)
	
	# accept it, logic to deny in here aswell - perhaps if he is not in the lobby?
	Steam.acceptP2PSessionWithUser(remoteID)
	
	_make_p2p_handshake() # acknowledge the session request, accept it and then send a handshake back

func _on_p2p_session_connect_fail(lobbyID:int, session_error:int):
	# List of possible errors returned by SendP2PPacket
	if session_error == 0: # k_EP2PSessionErrorNone - no error
		print("Session failure with %s [no error given.]" % str(lobbyID))
	elif session_error == 1: # k_EP2PSessionErrorNotRunningApp - player is not running the same game
		print("Session failure with %s [not running the same game.]" % str(lobbyID))
	elif session_error == 2: # k_EP2PSessionErrorNoRightsToApp - player doesnt own the game
		print("Session failure with %s [player doesn't own the game.]" % str(lobbyID))
	elif session_error == 3: # k_EP2PSessionErrorDestinationNotLoggedIn - player isn't connected to steam
		print("Session failure with %s [player isn't connected to Steam.]" % str(lobbyID))
	elif session_error == 4: # k_EP2PSessionErrorTimeout - connection timed out
		print("Session failure with %s [connection timed out.]" % str(lobbyID))
	elif session_error == 5: # k_EP2PSessionErrorMax - unused
		print("Session failure with %s [unused]" % str(lobbyID))
	else: # unknown error happened 
		print("Session failure with %s [unknown error]" % str(lobbyID))
