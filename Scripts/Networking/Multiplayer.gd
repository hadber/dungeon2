extends Node
const PlayerScene = preload("res://Scenes/Player.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	# warning-ignore:return_value_discarded
	$"../Networking".connect("lobby_members_changed", self, "_on_Lobby_members_changed")
	# warning-ignore:return_value_discarded
	Steam.connect("lobby_chat_update", self, "_on_Lobby_Chat_Update")
	
func _process(_delta):
	_read_P2P_Packet()
	
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
			if Global.PLAYERS.has(str(READABLE["from"])):
				Global.PLAYERS.get(str(READABLE["from"])).test_func()
		#if Global.PLAYERS.has(str(playerID)):
		#	Global.PLAYERS.get(str(playerID)).queue_free()
		# Print the packet to output
		#print("Packet: " + str(READABLE))

		# Append logic here to deal with packet data

func _send_P2P_Packet(data, send_type, channel):
	
	# If there is more than one user, send packets
	if Global.LOBBY_MEMBERS.size() > 1:
	
		# Loop through all members that aren't you
		for MEMBER in Global.LOBBY_MEMBERS:
			if MEMBER['steam_id'] != Global.STEAM_ID:
				# warning-ignore:return_value_discarded
				Steam.sendP2PPacket(MEMBER['steam_id'], data, send_type, channel)
				print('sending package' + str(data))

func _on_Lobby_Chat_Update(_lobbyID, _changedID, makingChangeID, chatState):

	# Get the user who has made the lobby change
	var CHANGER = Steam.getFriendPersonaName(makingChangeID)

	# If a player has joined the lobby
	if chatState == 1:
		print(str(CHANGER) + " has joined the lobby.")
		Global.ChatNode.add_chat(str(CHANGER) + " has joined the game.")
		var Player2 = PlayerScene.instance()
		Player2.get_node("CenterContainer/Name").text = CHANGER
		Player2.get_node("Sprite").modulate = Color("#0000ff")
		get_parent().add_child(Player2)
		Global.PLAYERS[str(makingChangeID)] = Player2

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


func _on_Lobby_members_changed():
	pass
	#for player in Global.PLAYERS:
	#	if not Global.NAMES.has(player.get_node("CenterContainer/Name").text):
	#		pass # fix it later lol
			#player.queue_free()
			#Global.PLAYERS.erase(player)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
