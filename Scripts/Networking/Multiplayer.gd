extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	# warning-ignore:return_value_discarded
	$"../Networking".connect("lobby_members_changed", self, "_on_Lobby_members_changed")
	
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

		# Print the packet to output
		print("Packet: " + str(READABLE))

		# Append logic here to deal with packet data

func _send_P2P_Packet(data, send_type, channel):
	
	# If there is more than one user, send packets
	if Global.LOBBY_MEMBERS.size() > 1:
	
		# Loop through all members that aren't you
		for MEMBER in Global.LOBBY_MEMBERS:
			if MEMBER['steam_id'] != Global.STEAM_ID:
				# warning-ignore:return_value_discarded
				Steam.sendP2PPacket(MEMBER['steam_id'], data, send_type, channel)

func _on_Lobby_members_changed():
	for player in Global.PLAYERS:
		if not Global.NAMES.has(player.get_node("CenterContainer/Name").text):
			pass # fix it later lol
			#player.queue_free()
			#Global.PLAYERS.erase(player)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
