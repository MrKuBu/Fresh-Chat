
util.AddNetworkString("freshChat.sendChatMessage")
util.AddNetworkString("freshChat.sendChatMessageToClient")
util.AddNetworkString("freshChat.sendChatMessageChatPrint")

util.AddNetworkString("freshChat.sendNewChatRoom")
util.AddNetworkString("freshChat.updateChatRoomList")
util.AddNetworkString("freshChat.broadcastChatRoomList")
util.AddNetworkString("freshChat.removeChatRoom")
util.AddNetworkString("freshChat.creatorRemovedRoom")
util.AddNetworkString("freshChat.broadcastNewChatRoom")

freshChat.CreatedRoom = {}
freshChat.ChatRooms = freshChat.ChatRooms or {}


hook.Add("Initialize", "freshChat.AddDefaultRooms", function()
	for _, room in pairs(freshChat['config']['defaultRooms'])do
		table.insert(freshChat.ChatRooms, { NAME = room.name, 
											ACCESS = room.canAccess, 
											CHAT = {}, 
											LIST = room.accessList, 
											CREATOR = nil } )
	end
end)

hook.Add("PlayerDisconnected", "freshChat.PlayerDisconnected", function( ply )
	if freshChat['config']['playerConnectionMessages'] then
		for _, _ply in pairs( player.GetAll() ) do
			local msg = freshChat['config']['playerDisconnectedMessage'](ply)
			_ply:ChatPrint( msg )
		end
	end

	if table.HasValue(freshChat.CreatedRoom, ply:SteamID()) then
		local room = freshChat.getRoomFromCreator( ply )
		freshChat.removeRoom( room )
	end
end)

hook.Add("PlayerInitialSpawn", "freshChat.PlayerInitialSpawn", function( ply )
	if freshChat['config']['playerConnectionMessages'] then
		for _, _ply in pairs( player.GetAll() ) do
			local msg = freshChat['config']['playerConnectedMessage'](ply)
			_ply:ChatPrint( msg )
		end
	end

	freshChat.broadcastRooms( ply )

	ply.lastChatMessageTime = 0
	ply.lastChatMessage = ""
end)

hook.Add("PlayerSay", "freshChat.GlobalChat", function( ply, message, tChat )
	if not freshChat.spamFiltering( ply, message ) then return "" end
end)

function freshChat.removeRoom( room )
	net.Start("freshChat.removeChatRoom")
	net.WriteString( room.NAME )
	net.WriteEntity( room.CREATOR )
	net.Broadcast()

	table.RemoveByValue( freshChat.CreatedRoom, room.CREATOR:SteamID() )
	table.RemoveByValue( freshChat.ChatRooms, room )
end

function freshChat.getRoomFromCreator( ply )
	for _, room in pairs(freshChat.ChatRooms)do
		if room.CREATOR == ply then
			return room
		end
	end
end

function freshChat.broadcastRooms( ply )
	for _, room in pairs(freshChat.ChatRooms) do
		net.Start("freshChat.broadcastNewChatRoom")
		net.WriteString( room.NAME )
		net.WriteEntity( room.CREATOR )
		net.WriteTable( room.LIST )
		net.Send( ply )
	end
end

function freshChat.spamFiltering( ply, message )
	if freshChat['config']['canBypassChatSpam'](ply) then
		return true
	end

	if ply.lastChatMessageTime > os.time() then
		ply:ChatPrint("Message was not sent due to spam protection.")
		return false
	end

	if message == ply.lastChatMessage and freshChat['config']['chatR9KMode'] then
		ply:ChatPrint("Message was not sent for being the same as the previous message.")
		return false
	end

	ply.lastChatMessageTime = os.time() + freshChat['config']['chatMessageTimeLimit']
	ply.lastChatMessage = message
	return true
end

net.Receive("freshChat.creatorRemovedRoom", function( len, ply )
	if table.HasValue(freshChat.CreatedRoom, ply:SteamID()) then
		local room = freshChat.getRoomFromCreator( ply )
		freshChat.removeRoom( room )
	end
end)

net.Receive("freshChat.updateChatRoomList", function( len, ply )
	local roomNum = net.ReadFloat()
	local accessList = net.ReadTable()
	local room = freshChat.ChatRooms[roomNum]

	if room.CREATOR == ply then
		room.LIST = accessList
		net.Start("freshChat.broadcastChatRoomList")
		net.WriteFloat( roomNum )
		net.WriteTable( accessList )
		net.Broadcast()
	end
end)

net.Receive("freshChat.sendNewChatRoom", function( len, ply )
	if table.HasValue( freshChat.CreatedRoom, ply:SteamID() ) then return end

	local name = net.ReadString()
	local accessList = net.ReadTable()

	table.insert(freshChat.CreatedRoom, ply:SteamID() )
	table.insert(freshChat.ChatRooms, { NAME = name, 
										ACCESS = freshChat['config']['defaultAccessToRooms'], 
										CHAT = {}, 
										LIST = accessList, 
										CREATOR = ply } )

	net.Start("freshChat.broadcastNewChatRoom")
	net.WriteString( name )
	net.WriteEntity( ply )
	net.WriteTable( accessList )
	net.Broadcast()
end)

net.Receive("freshChat.sendChatMessage", function( len, ply )
	local tChat = net.ReadFloat()
	local room = net.ReadFloat()
	local message = net.ReadString()
	local roomObj = freshChat.ChatRooms[room]
	local hasAccess = roomObj.ACCESS( ply ) or ply == roomObj.CREATOR
	if not hasAccess and table.HasValue( roomObj.LIST, ply:SteamID64() ) then
		hasAccess = true
	end

	if not hasAccess then return end
	if not freshChat.spamFiltering( ply, message ) then return end

	for _, _ply in pairs(player.GetAll())do

		local plyHasAccess = roomObj.ACCESS( _ply ) or _ply == roomObj.CREATOR
		if not plyHasAccess and table.HasValue( roomObj.LIST, _ply:SteamID64() ) then
			plyHasAccess = true
		end

		if plyHasAccess then
			net.Start("freshChat.sendChatMessageToClient")
			net.WriteFloat( tChat )
			net.WriteFloat( room )
			net.WriteEntity( ply )
			net.WriteString( message )
			net.Send(_ply)
		end
	end

end)
