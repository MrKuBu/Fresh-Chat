

local Player = FindMetaTable("Player")

function freshChat.getPlayer( id )
	for _, ply in pairs(player.GetAll())do
		if ply:SteamID64() == id then
			return ply
		end
	end
end

function freshChat.getRoomByCreator( ply )
	for _, room in pairs(freshChat.ChatRooms)do
		if room.CREATOR == ply then
			return room
		end
	end
end

function freshChat.bannedWordString( word )
	local str = ""

	for _ = 1, #word do
		str = str .. table.Random( freshChat['config']['wordFilterCharacters'] )
	end

	return str
end

function Player:ChatPrint( msg )
	net.Start("freshChat.sendChatMessageChatPrint")
	net.WriteString( msg )
	net.Send(self)
end 