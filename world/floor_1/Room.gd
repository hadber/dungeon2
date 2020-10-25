extends Node

var STEAM_USERNAME = ""
var STEAM_LOBBY_ID = 0
var LOBBY_MEMBERS = []
var DATA
var LOBBY_INVITE_ARG = false

func _input(event):
	if event.is_action_pressed("connectivity"):
		#print(Steam.AVATAR_SMAL)
		Steam.getPlayerAvatar(2) # [1 - 3], SMALL to LARGE
		#Steam.getMediumFriendAvatar(Global.STEAM_ID)

func _process(delta):
#	_read_P2P_Packet()
	pass
	
func _ready():
	Steam.connect("avatar_loaded", self, "loaded_avatar")
	Steam.connect("lobby_created", self, "_on_Lobby_Created")
	Steam.connect("lobby_match_list", self, "_on_Lobby_Match_List")
	Steam.connect("lobby_joined", self, "_on_Lobby_Joined")
	Steam.connect("lobby_chat_update", self, "_on_Lobby_Chat_Update")
	Steam.connect("lobby_message", self, "_on_Lobby_Message")
	Steam.connect("lobby_data_update", self, "_on_Lobby_Data_Update")
	Steam.connect("lobby_invite", self, "_on_Lobby_Invite")
	Steam.connect("join_requested", self, "_on_Lobby_Join_Requested")
	Steam.connect("p2p_session_request", self, "_on_P2P_Session_Request")
	Steam.connect("p2p_session_connect_fail", self, "_on_P2P_Session_Connect_Fail")
	# Check for command line arguments
	#_check_Command_Line()

"""
func _check_Command_Line():
	var ARGUMENTS = OS.get_cmdline_args()

	# There are arguments to process
	if ARGUMENTS.size() > 0:

		# Loop through them and get the useful ones
		for ARGUMENT in ARGUMENTS:
			print("Command line: "+str(ARGUMENT))

			# An invite argument was passed
			if LOBBY_INVITE_ARG:
				_join_Lobby(int(ARGUMENT))

			# A Steam connection argument exists
			if ARGUMENT == "+connect_lobby":
				LOBBY_INVITE_ARG = true
"""
func loaded_avatar(id, size, buffer):
	print("Avatar for user: " + str(id))
	print("Size: " + str(size))
	# Create a new image and texture to fill out
	var AVATAR = Image.new()
	var AVATAR_TEXTURE = ImageTexture.new()
	AVATAR.create(size, size, false, Image.FORMAT_RGBAF)

	# Lock the image and fill the pixels from the data buffer
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

	# Now apply the texture
	AVATAR_TEXTURE.create_from_image(AVATAR)

	# For our purposes, set a sprite with the avatar texture
	$AvatarSprite.set_texture(AVATAR_TEXTURE)
