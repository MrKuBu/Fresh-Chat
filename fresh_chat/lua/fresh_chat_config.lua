freshChat['config'] = {}

-- How wide in pixels the chat box will be
freshChat['config']['width'] = 750

-- How tall in pixels the chat box will be
freshChat['config']['height'] = 350

-- The pixel offset from the left of the screen for the chat box
freshChat['config']['offsetX'] = 20

-- The pixel offest from the bottom of the screen for the chat box
freshChat['config']['offsetY'] = 180

-- The limit for web emotes per message
-- More web emotes will create lag, so i would recommend to
-- keep this number low
freshChat['config']['webEmoteLimit'] = 5

-- The time it takes before you can post a new chat message ( in seconds )
freshChat['config']['chatMessageTimeLimit'] = 1

-- Return what players you want to be able to bypass all the anti-spam filters
freshChat['config']['canBypassChatSpam'] = function( ply )
	return ply:IsAdmin() or ply:IsSuperAdmin()
end

-- R9K Mode
-- 2 consecutive messages cannot be the same
freshChat['config']['chatR9KMode'] = false

-- Prints into chat when a player leaves the server or joins the server
freshChat['config']['playerConnectionMessages'] = true

-- The message to be printed when a person joins the server
freshChat['config']['playerConnectedMessage'] = function( ply )
	return string.format( "%s has connected to the server! (%s)", ply:Nick(), ply:SteamID() )
end

-- The message to be printed when a person leaves the server
freshChat['config']['playerDisconnectedMessage'] = function( ply )
	return string.format( "%s has disconnected from the server! (%s)", ply:Nick(), ply:SteamID() )
end

-- Return what type of player(s) can create private rooms
freshChat['config']['canAddChatRoom'] = function( ply )
	return true
end

-- How long a message will stay in the preview (when the chat box is not open)
freshChat['config']['chatPreviewDuration'] = 8

-- Default rooms that will be added to the room list
-- !!! Do not remove the global room !!!
freshChat['config']['defaultRooms'] = {
	-- I would recommend you not change anything in the global room
	{
		name = "Global",
		accessList = {},
		canAccess = function( ply )
			return true 
		end
	},

	{
		name = "Admin",
		accessList = {}, -- You can place a list of 64 bit steam ids in here
		canAccess = function( ply )
			return ply:IsAdmin()
		end
	}
}

-- Return what player(s) can have access to all rooms
freshChat['config']['defaultAccessToRooms'] = function( ply )
	return ply:IsAdmin()
end

-- Return what player(s) get what chat tags
freshChat['config']['chatTags'] = function( ply )
	if not ply then return "" end

	if ply:IsAdmin() then
		return "ADMIN" end

	if ply:IsSuperAdmin() then
		return "SUPERADMIN" end

	return ""
end

-- Return what players can remove messages from the chat
freshChat['config']['canRemoveMessages'] = function( ply )
	return ply:IsSuperAdmin()
end

-- When the string is typed in chat, it will be replaced with the image specified in the 
-- second argument. ( If the player has emotes / webemotes enables in their settings )
freshChat['config']['emotes'] = {
	{ ":)", Material("icon16/emoticon_smile.png") },
	{ ":D", Material("icon16/emoticon_grin.png") },
	{ ">:D", Material("icon16/emoticon_evilgrin.png") },
	{ "8D", Material("icon16/emoticon_happy.png") },
	{ ":O", Material("icon16/emoticon_surprised.png") },
	{ ":0", Material("icon16/emoticon_surprised.png") },
	{ ":o", Material("icon16/emoticon_surprised.png") },
	{ ":P", Material("icon16/emoticon_tongue.png") },
	{ ":p", Material("icon16/emoticon_tongue.png") },
	{ ":(", Material("icon16/emoticon_unhappy.png") },
	{ ":3", Material("icon16/emoticon_waii.png") },
	{ ";)", Material("icon16/emoticon_wink.png") },
	{ ";D", Material("icon16/emoticon_wink.png") },
	{ ":illuminati:", Material("icon16/eye.png") },
	{ ":football:", Material("icon16/sport_football.png") },
	{ ":basketball:", Material("icon16/sport_basketball.png") },
	{ ":golf:", Material("icon16/sport_golf.png") },
	{ ":raquet:", Material("icon16/sport_raquet.png") },
	{ ":soccer:", Material("icon16/sport_soccer.png") },
	{ ":tennis:", Material("icon16/sport_tennis.png") },
	{ ":star:", Material("icon16/star.png") },
	{ ":car:", Material("icon16/car.png") },
	{ ":world:", Material("icon16/world.png") },
	{ ":cake:", Material("icon16/cake.png") },
	{ ":linux:", Material("icon16/tux.png") },
	{ ":bug:", Material("icon16/bug.png") },
	{ ":money:", Material("icon16/money.png") },
	{ "$", Material("icon16/money_dollar.png") },
	{ "<3", Material("icon16/heart.png") },
	{ "<|", Material("icon16/ruby.png") },
	{ "->", Material("icon16/arrow_right.png") },
	{ "<-", Material("icon16/arrow_left.png") },

	-- When adding a web emote, make sure the url starts with 
	-- http:// or https:// or it will not work. Also add the width and 
	-- height to table. This helps get the aspect ratio of the image to 
	-- scale it down to fit in the chat.

	-- recent discovery, awesomium doesn't like .gifv, so you'll need to 
	-- convert them or it will crash clients
	-- giphy.com is a great site to find some working ones
	{ ":cry:", "http://i.imgur.com/RCz5EaV.gif", 350, 198 },
	{ ":finessed:", "http://i.imgur.com/g4S1ULH.gif", 384, 219 },
	{ ":gj:", "http://i.imgur.com/jWKG5bw.gif", 300, 225 },
	{ ":booty:", "http://i.imgur.com/TxE6A6X.gif", 310, 203 },
	{ ":facepalm:", "http://media.giphy.com/media/kwQfk9zUJ6eVq/giphy.gif", 200, 150 },
	{ ":ok:", "https://media4.giphy.com/media/1zSiX3p2XEZpe/200.gif", 200, 200 },
	{ ":cyrus:", "http://media.giphy.com/media/idb5m5EXydy2A/giphy.gif", 260, 146 },
}

-- When the string is typed it will not appear in the message and will color
-- every letter up until a new color string the color in the second argument.
freshChat['config']['colors'] = {
	{ "^1", Color(239, 72, 54) }, // red
	{ "^2", Color(89, 171, 227) }, // light blue
	{ "^3", Color(31, 58, 147) }, // blue
	{ "^4", Color(1, 152, 117) }, // green
	{ "^5", Color(249, 105, 14) }, // orange
	{ "^6", Color(142, 68, 173) }, // purple
	{ "^7", Color(190, 144, 212) }, // pink
	{ "^8", Color(171, 183, 183) }, // gray
	{ "^9", Color(0, 0, 0, 200) }, // default
	{ "^0", Color(0, 0, 0) } // black
}

-- Enabled the word filtering
freshChat['config']['wordFiltering'] = true

-- The list of all the words that will be filtered out of chat
freshChat['config']['wordFilterList'] = {
	"fuck",
	"shit",
	"tomato"
}

-- The characters that will replace the banned word in chat
freshChat['config']['wordFilterCharacters'] = { 
	"%", "$", "#", "&", "!", "?", "@", "/" 
}