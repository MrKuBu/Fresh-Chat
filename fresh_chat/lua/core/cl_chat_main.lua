
local Player = FindMetaTable("Player")

freshChat.CurrentRoom = freshChat.CurrentRoom or 1
freshChat.ChatRooms = freshChat.ChatRooms or {}
freshChat.MissedMessages = freshChat.MissedMessages or {}
freshChat.chatIsOpen = freshChat.chatIsOpen or false
freshChat.ReceivedRooms = freshChat.ReceivedRooms or false

hook.Add("Initialize", "freshChat.AddDefaultRooms", function()
	freshChat:init()

	GAMEMODE.StartChat = function( s, tChat )
		return true
	end
end)

hook.Add( "PlayerBindPress", "freshChat.openChat", function( ply, bind, pressed )
	local tChat = false

	if bind == "messagemode2" or bind == "messagemode" then
		tChat = bind == "messagemode2"
	else
		return
	end

	if not freshChat.chatIsOpen then
		freshChat:openChat( "", tChat )
	end
	

	return true
end )

hook.Add("HUDShouldDraw", "freshChat.HideDefaultChat", function( elem )
	if elem == "CHudChat" then
		return false
	end
end)

hook.Add("Think", "freshChat.CloseChat", function( ply, key )
	if ValidPanel(freshChat.chatBox) and input.IsKeyDown(KEY_ESCAPE) then
		freshChat:closeChat()
		RunConsoleCommand("cancelselect")
	end
end)

hook.Add( "ChatText", "hide_joinleave", function( index, name, text, typ )
	return true
end)

hook.Add("OnPlayerChat", "freshChat.OnPlayerChat", function( ply, message, tChat, dead, other )
	ply = IsValid(ply) and ply:SteamID64() or "ANNOUNCEMENT"

	if other != nil then
		local darkrp = string.find( other, "(OOC)" ) or string.find( other, "(group)" )
		if darkrp then return end
	end

	local lang = GetConVarString( "freshchat_tts_lan" )
	local str = string.Replace( message, " ", "%20" )
	if tobool(GetConVarNumber( "freshchat_tts" )) then
		--sound.PlayURL("http://translate.google.com/translate_tts?tl=" .. lang .. "&q=" .. str,"",function() end) -- Старая версия спетча
		sound.PlayURL("http://translate.google.com/translate_tts?ie=UTF-8&tl=".. lang .."&client=tw-ob&q=".. str,"",function() end)
	end

	freshChat.createMessage( 1, tChat, dead, ply, message )
	freshChat.saveChatMessage( 1, tChat, dead, ply, message )
end)

function freshChat.createMessage( room, tChat, dead, ply, message )
	if not freshChat.ReceivedRooms then return end

	if freshChat.CurrentRoom == room then
		if freshChat.chatIsOpen then
			local col = (#freshChat.ChatRooms[ room ].CHAT+1) % 2 == 0 and color_white or Color(250,250,250)
			freshChat.chatBox:CreateMessage( room, tChat, dead, ply, message, col )
		elseif ValidPanel(freshChat.chatPrev) then
			freshChat.chatPrev:AddMessage( tChat, dead, ply, message ) 
		end
	end
end

function freshChat.saveChatMessage( room, tChat, dead, ply, msg )
	if not freshChat.ReceivedRooms then return end

	local chatRoom = freshChat.ChatRooms[ room ].CHAT
	local Ttbl = {
		tChat = tChat,
		dead = dead,
		caller = ply,
		message = msg
	}

	table.insert( chatRoom, Ttbl )

	if freshChat.CurrentRoom != room then
		if not freshChat.MissedMessages[ room ] then
			freshChat.MissedMessages[ room ] = 1
		else
			freshChat.MissedMessages[ room ] = freshChat.MissedMessages[ room ] + 1
		end
	else
		freshChat.MissedMessages[ room ] = 0
	end
end

function freshChat.removeChatMessage( room, ply, message )
	local tbl = freshChat.ChatRooms[ room ].CHAT
	for _, msg in pairs(tbl)do
		if ply == msg.caller and message == msg.message then
			table.remove( freshChat.ChatRooms[ room ].CHAT, _ )
		end
	end
end

function freshChat.removeRoom()
	net.Start("freshChat.creatorRemovedRoom")
	net.SendToServer()
end

function freshChat.colorToString( col )
	return string.format( "@Color[%d,%d,%d,%d]", col.r, col.g, col.b, col.a )
end

function freshChat.getRoomFromCreator( ply, name )
	for _, room in pairs(freshChat.ChatRooms)do
		if room.CREATOR == ply and room.NAME == name then
			return room
		end
	end
end

function Player:ChatPrint( msg )
	local ply = "ANNOUNCEMENT"

	freshChat.createMessage( 1, false, false, ply, msg )
	freshChat.saveChatMessage( 1, false, false, ply, msg )
end 

function player.getByName( name )
	for _, ply in pairs( player.GetAll() ) do
		if ply:Nick() == name then
			return ply
		end
	end
end

chat.AddText = function( ... ) 
	local tbl = { ... }
	local str = ""
	local ply = "ANNOUNCEMENT"

	if tbl[1] == "Console" then return end
	if tbl[2] == "(TEAM) " then return end
	if tbl[2] == "*DEAD* " then return end
	if DarkRP and player.getByName( tbl[2] ) then return end

	

	if not IsColor(tbl[1]) and not isstring(tbl[1]) then return end 

	for _, val in pairs(tbl)do
		if IsColor(val) then
			str = str .. " " .. freshChat.colorToString( val ) .. " "
		elseif isstring(val) then
			str = str .. val
		end
	end

	freshChat.createMessage( 1, false, false, ply, str )
	freshChat.saveChatMessage( 1, false, false, ply, str )
end

net.Receive("freshChat.broadcastChatRoomList", function( len )
	local roomNum = net.ReadFloat()
	local accessList = net.ReadTable()

	freshChat.ChatRooms[roomNum].LIST = accessList
end)

net.Receive("freshChat.sendChatMessageChatPrint", function( len )
	local msg = net.ReadString()
	local ply = "ANNOUNCEMENT"

	freshChat.createMessage( 1, false, false, ply, msg )
	freshChat.saveChatMessage( 1, false, false, ply, msg )

end)

net.Receive("freshChat.removeChatRoom", function( len )
	local name = net.ReadString()
	local creator = net.ReadEntity()

	local room = freshChat.getRoomFromCreator( creator, name )

	if room then
		table.RemoveByValue( freshChat.ChatRooms, room )
		freshChat.CurrentRoom = 1
		if ValidPanel(freshChat.chatBox) then
			freshChat.chatBox:CreateRooms()
			freshChat.chatBox:RemoveRoomButtons()
			freshChat.chatBox:CreateSavedMessages()
			freshChat.MissedMessages[ 1 ] = 0
		end
	end
end)

net.Receive("freshChat.sendChatMessageToClient", function( len )
	local tChat = tobool(net.ReadFloat())
	local room = net.ReadFloat()
	local ply = net.ReadEntity()
	local message = net.ReadString()
	local dead = not ply:Alive()

	freshChat.createMessage( room, tChat, dead, ply:SteamID64(), message )
	freshChat.saveChatMessage( room, tChat, dead, ply:SteamID64(), message )
end)

net.Receive("freshChat.broadcastNewChatRoom", function( len )
	freshChat.ReceivedRooms = true

	local name = net.ReadString()
	local creator = net.ReadEntity()
	local accessList = net.ReadTable()

	table.insert(freshChat.ChatRooms, { NAME = name, 
										ACCESS = freshChat['config']['defaultAccessToRooms'], 
										CHAT = {}, 
										LIST = accessList, 
										CREATOR = creator } )
	if ValidPanel(freshChat.chatBox) then
		freshChat.chatBox:CreateRooms()
	end
end)

function freshChat:openChat( text, tChat )
	self.chatIsOpen = true
	gui.EnableScreenClicker(true)
	gamemode.Call( "StartChat" )

	if ValidPanel(self.chatPrev) then
		self.chatPrev:Remove()
		self.chatPrev = nil
	end

	self.chatBox = vgui.Create("DFreshChatBox")
	self.chatBox:SetPos( freshChat['config']['offsetX'], ScrH()-(self.chatBox:GetTall()+freshChat['config']['offsetY']) )
	self.chatBox:SetTeamChat( tChat )
end

function freshChat:closeChat()
	self.chatIsOpen = false
	gamemode.Call( "FinishChat" )

	if ValidPanel(self.chatBox) then
		self.chatBox:Remove()
		self.chatBox = nil
		gui.EnableScreenClicker(false)

		self.chatPrev = vgui.Create("DFreshChatNotifications")
		self.chatPrev:SetPos( freshChat['config']['offsetX'], ScrH()-(self.chatPrev:GetTall()+freshChat['config']['offsetY']) )
	end
end

function freshChat:init()
	self.chatPrev = vgui.Create("DFreshChatNotifications")
	self.chatPrev:SetPos( freshChat['config']['offsetX'], ScrH()-(self.chatPrev:GetTall()+freshChat['config']['offsetY']) )
end
