local PANEL = {}

PANEL.TeamChat = false
PANEL.HeaderBoxHeight = 36
PANEL.SubHeaderBoxHeight = 40
PANEL.ChatRoomMenuWidth = 130

PANEL.grad_down = surface.GetTextureID( "vgui/gradient_down" )
PANEL.grad_up = surface.GetTextureID( "vgui/gradient_up" )

PANEL.lock = Material( "icon16/lock.png" )
PANEL.cog = Material( "icon16/cog.png" )
PANEL.cross = Material( "icon16/cross.png" )
PANEL.tux = Material( "icon16/tux.png" )

surface.CreateFont("freshChat.HeaderTitle", { font = "Roboto", size = 16, weight = 200 })
surface.CreateFont("freshChat.SubHeaderTitle", { font = "Roboto", size = 14, weight = 800 })
surface.CreateFont("freshChat.NewRoomPlus", { font = "Roboto", size = 20, weight = 2000 })
surface.CreateFont("freshChat.NewRoomText", { font = "Roboto", size = 11, weight = 800 })
surface.CreateFont("freshChat.RoomFont", { font = "Roboto", size = 12, weight = 800 })
surface.CreateFont("freshChat.MarlettSymbols", { font = "Marlett", size = 14, symbol = true })
surface.CreateFont("freshChat.TextEntryFiller", { font = "Roboto", size = 12, italic = true })

surface.CreateFont("freshChat.ChatFont", { font = "Roboto", size = 13, weight = 800 })

function PANEL:Init()
	self:SetSize( freshChat['config']['width'], freshChat['config']['height'] )
	self.InputText = ""
	self.roomButtons = {}

	self.closeBtn = vgui.Create( "DButton", self)
	self.closeBtn:SetPos( self:GetWide()-self.HeaderBoxHeight, 0 )
	self.closeBtn:SetSize( self.HeaderBoxHeight, self.HeaderBoxHeight )
	self.closeBtn:SetText("")
	self.closeBtn:SetDrawBackground(false)
	self.closeBtn.Paint = function( s, w, h )
		draw.SimpleText( "r", "freshChat.MarlettSymbols", w*0.5, h*0.5, Color(149,156,172), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	self.closeBtn.DoClick = function()
		freshChat:closeChat()
	end

	self.settings = vgui.Create( "DButton", self)
	self.settings:SetPos( self:GetWide()-30, self.HeaderBoxHeight )
	self.settings:SetSize( 20, self.SubHeaderBoxHeight )
	self.settings:SetText("")
	self.settings:SetDrawBackground(false)
	self.settings.Paint = function( s, w, h )
		surface.SetDrawColor(Color( 0, 0, 0, 130 ))
		surface.SetMaterial( self.cog )
		surface.DrawTexturedRect( w/2-8, h/2-8, 16, 16 )
	end
	self.settings.DoClick = function()
		if not IsValid( self.settingsContainer ) then
			self.settingsContainer = vgui.Create( "DFreshChatSettings" )
			local parentX, parentY = self:GetPos()
			local btnX, btnY = self.settings:GetPos()
			self.settingsContainer:SetPos( parentX + btnX + 20, parentY + btnY - 10 )
		else
			self.settingsContainer:Remove()
			self.settingsContainer = nil
		end
	end

	self.emoteBtn = vgui.Create( "DButton", self)
	self.emoteBtn:SetPos( 0, self.HeaderBoxHeight )
	self.emoteBtn:SetSize( 20, self.SubHeaderBoxHeight )
	self.emoteBtn:SetText("")
	self.emoteBtn:SetDrawBackground(false)
	self.emoteBtn.Paint = function( s, w, h )
		surface.SetDrawColor(Color( 0, 0, 0, 130 ))
		surface.SetMaterial( self.tux )
		surface.DrawTexturedRect( w/2-8, h/2-8, 16, 16 )
	end
	self.emoteBtn.DoClick = function()
		if not IsValid( self.emoteContainer ) then
			self.emoteContainer = vgui.Create( "DFreshChatEmotes" )
			local parentX, parentY = self:GetPos()
			local btnX, btnY = self.emoteBtn:GetPos()
			self.emoteContainer:SetPos( parentX + btnX + 20, parentY + btnY - 10 )
			self.emoteContainer:SetMainWindow( self )
		else
			self.emoteContainer:Remove()
			self.emoteContainer = nil
		end
	end
	self.emoteBtn:MoveLeftOf( self.settings, 5 )

	if freshChat['config']['canAddChatRoom'](LocalPlayer()) then
		self.newRoomBtn = vgui.Create( "DButton", self)
		self.newRoomBtn:SetPos( 20, self.HeaderBoxHeight + self.SubHeaderBoxHeight + 20 )
		self.newRoomBtn:SetSize( self.ChatRoomMenuWidth-40, 25 )
		self.newRoomBtn:SetText("")
		self.newRoomBtn:SetDrawBackground(false)
		self.newRoomBtn.Paint = function( s, w, h )
			draw.RoundedBox( 4, 0, 0, w, h, Color(0,0,0,30) )
			draw.RoundedBox( 4, 1, 1, w-2, h-2, Color(0,0,0,60) )

			w, h = w-2, h-2

			draw.RoundedBox( 2, 0, 0, w, h, Color(94,158,213) )
			draw.RoundedBox( 0, 1, 1, w-2, 1, Color(255,255,255,70) )
			draw.RoundedBox( 2, 1, 2, w-2, h-3, Color(108,181,244) )

			draw.SimpleText( "+", "freshChat.NewRoomPlus", 10, h*0.5-2, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
			draw.SimpleText( "NEW ROOM", "freshChat.NewRoomText", 25, h*0.5, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		end
		self.newRoomBtn.DoClick = function( s )
			if not IsValid( self.newRoom ) then
				self.newRoom = vgui.Create( "DFreshChatRoom" )
				self.newRoom:SetMainWindow( self )
			else
				self.newRoom:Remove()
				self.newRoom = nil
			end
		end
	end

	self:CreateRooms()

	local startX = freshChat['config']['offsetX']+1
	local startY = ScrH()-(self:GetTall()+freshChat['config']['offsetY'])
	self.textBoxContainer = vgui.Create( "DFrame", self )
	self.textBoxContainer:SetPos( startX+self.ChatRoomMenuWidth, startY+(self:GetTall()-30) )
	self.textBoxContainer:SetSize( self:GetWide()-(self.ChatRoomMenuWidth+1), 30 )
	self.textBoxContainer:SetDraggable(false)
	self.textBoxContainer:ShowCloseButton( false )
	self.textBoxContainer:SetTitle("")
	self.textBoxContainer.Paint = function( s, w, h ) 
		draw.RoundedBox( 0, 0, 0, w, h, color_white )
	end
	self.textBoxContainer:MakePopup()

	self.textEntry = vgui.Create( "DTextEntry", self.textBoxContainer )
	self.textEntry:SetPos( 5, 5 )
	self.textEntry:SetSize( self.textBoxContainer:GetWide()-10, self.textBoxContainer:GetTall()-10 )
	self.textEntry:SetMultiline(false)
	self.textEntry.OnLoseFocus = function(t)
		self.textBoxContainer:KillFocus()
	end
	self.textEntry:SetText(self.InputText)
	self.textEntry.Paint = function( s, w, h )
		s.charLimit = freshChat.CurrentRoom == 1 and 126 or 2000
		local charsLeft = math.max(s.charLimit - #s:GetValue(), 0)
		local borderCol = charsLeft <= 0 and Color( 239, 72, 54 ) or  Color(210,210,210)

		draw.RoundedBox( 0, 0, 0, w, h, borderCol )
		draw.RoundedBox( 0, 1, 1, w-2, h-2, Color(255,255,255))
		s:DrawTextEntryText(Color(30, 30, 30), Color(108,181,244), Color(0, 0, 0))

		if s:GetValue() == "" then
			draw.SimpleText( self.TeamChat and "Say Team" or "Say", "freshChat.TextEntryFiller", 5, h/2, Color(0,0,0,130), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		end

		draw.SimpleText( charsLeft, "freshChat.TextEntryFiller", w - 5, h/2, Color(0,0,0,130), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
	end
	self.textEntry.OnEnter = function(s)
		-- send to server here
		if freshChat.CurrentRoom != 1 then
			net.Start("freshChat.sendChatMessage")
			net.WriteFloat( self.TeamChat and 1 or 0 )
			net.WriteFloat( freshChat.CurrentRoom )
			net.WriteString( s:GetValue() )
			net.SendToServer()
		else
			RunConsoleCommand( self.TeamChat and "say_team" or "say", s:GetValue() )
		end

		freshChat:closeChat()
	end
	self.textEntry.OnChange = function(s)
		hook.Call("ChatTextChanged", GM, s:GetValue())
	end
	self.textEntry:RequestFocus()

	self.chatContainer = vgui.Create( "DScrollPanel", self)
    self.chatContainer:SetSize( self:GetWide()-(self.ChatRoomMenuWidth+1), self:GetTall()-(self.HeaderBoxHeight + self.SubHeaderBoxHeight + 30 + 1) )
    self.chatContainer:SetPos( self.ChatRoomMenuWidth+1, self.HeaderBoxHeight + self.SubHeaderBoxHeight + 1 )
    self.chatContainer.VBar:SetWidth( 8 )
	self.chatContainer.VBar.Paint = function( s, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color(255,255,255))
	end
	self.chatContainer.VBar.btnUp.Paint = function() end
	self.chatContainer.VBar.btnDown.Paint = function() end
	self.chatContainer.VBar.btnGrip.Paint = function( s, w, h )
		draw.RoundedBox( 0, 0, 0, w, h+22, Color(0,0,0,90))
	end

	if freshChat.ChatRooms[freshChat.CurrentRoom].CREATOR == LocalPlayer() then
		self:CreateRoomButtons()
	end
	self:CreateSavedMessages()
end

function PANEL:RemoveRooms()
	for _, room in pairs(self.roomButtons)do
		if room and IsValid(room) then
			room:Remove()
		end
	end
end

function PANEL:CreateRooms()
	self:RemoveRooms()

	self.roomButtons = {}
	for _, room in pairs(freshChat.ChatRooms)do
		local hasAccess = room.ACCESS(LocalPlayer()) or room.CREATOR == LocalPlayer()
		if not hasAccess and (table.HasValue( room.LIST, LocalPlayer():SteamID64() ) or _ == 1) then
			hasAccess = true
		end

		self.roomButtons[_] = vgui.Create( "DButton", self )
		self.roomButtons[_]:SetPos( 0, self.HeaderBoxHeight + self.SubHeaderBoxHeight + 20 )
		self.roomButtons[_]:SetSize( self.ChatRoomMenuWidth, 24 )
		self.roomButtons[_]:SetText("")
		self.roomButtons[_]:SetDrawBackground(false)
		self.roomButtons[_]:SetDisabled( not hasAccess )
		self.roomButtons[_].Paint = function( s, w, h )
			local col = Color(0,0,0,150)
			if _ == freshChat.CurrentRoom then
				draw.RoundedBox( 0, 0, 0, w, h, Color(0,0,0,20) )
				draw.RoundedBox( 0, 0, 0, 3, h, Color(108,181,244) )
				col = Color(108,181,244)
			end

			if not hasAccess then
				surface.SetDrawColor(Color( 0, 0, 0, 130 ))
				surface.SetMaterial( self.lock )
				surface.DrawTexturedRect( 10, 6, 11, 12 )
			end

			draw.SimpleText( room.NAME, "freshChat.RoomFont", 30, h*0.5, col, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

			--freshChat.MissedMessages[ room ]
			local missed = freshChat.MissedMessages[ _ ] or 0
			if missed and missed > 0 and hasAccess then
				local missedStr = string.Comma( missed )
				surface.SetFont("freshChat.TextEntryFiller")
				local _w, _h = surface.GetTextSize( missedStr )
				draw.RoundedBox( 0, w-(_w+8+4), h*0.5 - 8, _w+8, 16, Color(108,181,244) )
				draw.SimpleText( missedStr, "freshChat.TextEntryFiller", w-(_w+4+4), h*0.5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
			end
		end
		self.roomButtons[_].DoClick = function()
			freshChat.CurrentRoom = _
			freshChat.MissedMessages[ _ ] = 0
			self:CreateSavedMessages()
			self:RemoveRoomButtons()
			if freshChat.ChatRooms[freshChat.CurrentRoom].CREATOR == LocalPlayer() then
				self:CreateRoomButtons()
			end
		end

		if _ == 1 then
			if self.newRoomBtn then
				self.roomButtons[_]:MoveBelow(self.newRoomBtn, 20)
			end
		else
			self.roomButtons[_]:MoveBelow(self.roomButtons[_-1], 2)
		end
	end
end

function PANEL:RemoveRoomButtons()
	if IsValid(self.roomSettings) then self.roomSettings:Remove() end
	if IsValid(self.remove) then self.remove:Remove() end
end

function PANEL:CreateRoomButtons()
	self:RemoveRoomButtons()

	self.roomSettings = vgui.Create( "DButton", self)
	self.roomSettings:SetPos( self.ChatRoomMenuWidth+10, self.HeaderBoxHeight )
	self.roomSettings:SetSize( 20, self.SubHeaderBoxHeight )
	self.roomSettings:SetText("")
	self.roomSettings:SetDrawBackground(false)
	self.roomSettings.Paint = function( s, w, h )
		surface.SetDrawColor(Color( 0, 0, 0, 130 ))
		surface.SetMaterial( self.cog )
		surface.DrawTexturedRect( w/2-8, h/2-8, 16, 16 )
	end
	self.roomSettings.DoClick = function()
		if not IsValid( self.roomSett ) then
			self.roomSett = vgui.Create( "DFreshChatRoomSettings" )
			local parentX, parentY = self:GetPos()
			local btnX, btnY = self.roomSettings:GetPos()
			self.roomSett:SetPos( parentX + btnX + 20, parentY + btnY - 10 )
			self.roomSett:SetMainWindow( self )
		else
			self.roomSett:Remove()
			self.roomSett = nil
		end
	end

	self.remove = vgui.Create( "DButton", self)
	self.remove:SetPos( self.ChatRoomMenuWidth+10, self.HeaderBoxHeight )
	self.remove:SetSize( 20, self.SubHeaderBoxHeight )
	self.remove:SetText("")
	self.remove:SetDrawBackground(false)
	self.remove.Paint = function( s, w, h )
		surface.SetDrawColor(Color( 0, 0, 0, 130 ))
		surface.SetMaterial( self.cross )
		surface.DrawTexturedRect( w/2-8, h/2-8, 16, 16 )
	end
	self.remove.DoClick = function()
		if not IsValid( self.confirmRemove ) then
			self.confirmRemove = vgui.Create( "DFreshChatConfirm" )
			local parentX, parentY = self:GetPos()
			local btnX, btnY = self.remove:GetPos()
			self.confirmRemove:SetPos( parentX + btnX + 20, parentY + btnY - 10 )
			self.confirmRemove:SetMainWindow( self )
		else
			self.confirmRemove:Remove()
			self.confirmRemove = nil
		end
	end

	self.remove:MoveRightOf( self.roomSettings, 5 )
end

function PANEL:CreateSavedMessages()
	local p = self.chatContainer
	self.lastChatMessage = nil
	p:Clear()
	local savedChat = freshChat.ChatRooms[ freshChat.CurrentRoom ].CHAT

	for _, msg in pairs(savedChat)do
		local col = _ % 2 == 0 and color_white or Color(250,250,250)
		self:CreateMessage( freshChat.CurrentRoom, msg.tChat, msg.dead, msg.caller, msg.message, col )
	end

	timer.Simple( 0.2, function()
		if ValidPanel(p.VBar) then
			p.VBar:AnimateTo(  p.VBar.CanvasSize, 0, 0, 8 )
		end
	end)
end

function PANEL:AddMessage( room, tChat, dead, caller, message )
	local Ctbl = freshChat.ChatRooms[ room ].CHAT
	local Ttbl = {
		tChat = tChat,
		dead = dead,
		caller = caller,
		message = message
	}

	local col = #freshChat.ChatRooms[ room ].CHAT % 2 == 0 and color_white or Color(250,250,250)
	self:CreateMessage( room, tChat, dead, caller, message, col )
	table.insert( Ctbl, Ttbl )
end

function PANEL:CreateMessage( room, tChat, dead, caller, message, col )
	local p = self.chatContainer

	self.lastChatMessage = self.lastChatMessage or nil
	if room == freshChat.CurrentRoom then
		local chatText
		if caller == "ANNOUNCEMENT" then
			chatText = vgui.Create("DFreshChatAnnounce", p)
			chatText:SetSize( p:GetWide(), 50 )
			chatText:SetChatInfo( message )
			chatText:SetShadows( false )
		else
			chatText = vgui.Create("DFreshChatMessage", p)
			chatText:SetSize( p:GetWide(), 50 )
			if isstring(caller) then
				chatText:SetPlayer( caller )
			else
				chatText:SetPlayer( caller:SteamID64() )
			end
			chatText:SetChatInfo( tChat, dead, message )
			chatText:SetShadows( false )
		end
		chatText:SetBGColor(col)
		chatText:SetPos( 0, 0 )

		if self.lastChatMessage then
			chatText:MoveBelow( self.lastChatMessage )
		end

		self.lastChatMessage = chatText

		p:AddItem( chatText )
	
	end
end

function PANEL:SetTextInput( strText )
	self.InputText = strText
end

function PANEL:SetTeamChat( boolTeam )
	self.TeamChat = boolTeam
end

function PANEL:Paint( w, h )
	draw.RoundedBox( 0, 0, 0, w, h, Color(230,230,230) )

	draw.RoundedBox( 0, 0, self.HeaderBoxHeight, w, self.SubHeaderBoxHeight, color_white ) -- sub header box
	draw.RoundedBox( 0, 0, self.HeaderBoxHeight+self.SubHeaderBoxHeight, w, 1, Color(0,0,0,30) ) -- sub header box bottom shade

	draw.SimpleText( "Chat Rooms", "freshChat.SubHeaderTitle", 20, self.HeaderBoxHeight + self.SubHeaderBoxHeight*0.5, Color(0,0,0), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

	draw.RoundedBox( 0, 0, self.HeaderBoxHeight + self.SubHeaderBoxHeight + 1, self.ChatRoomMenuWidth, h-(self.HeaderBoxHeight + self.SubHeaderBoxHeight), Color(245,245,245) ) -- chat room box
	draw.RoundedBox( 0, self.ChatRoomMenuWidth, self.HeaderBoxHeight + self.SubHeaderBoxHeight + 1, 1, h-(self.HeaderBoxHeight + self.SubHeaderBoxHeight), Color(0,0,0,30) ) -- left side shade

	draw.RoundedBox( 0, 0, 0, w, self.HeaderBoxHeight, Color(55,57,66) ) -- header box
	draw.RoundedBox( 0, 1, 0, w-2, 1, Color(255,255,255,5) ) -- top shade
	draw.RoundedBox( 0, 0, 0, 1, self.HeaderBoxHeight, Color(255,255,255,5) ) -- left shade
	draw.RoundedBox( 0, w-1, 0, 1, self.HeaderBoxHeight, Color(255,255,255,5) ) -- right shade
	
	draw.SimpleText( "CHAT", "freshChat.HeaderTitle", 20, self.HeaderBoxHeight*0.5, Color(149,156,172), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
end

function PANEL:PaintOver( w, h )
	surface.SetDrawColor( Color( 0, 0, 0, 60 ) )
	surface.SetTexture( self.grad_up )
	surface.DrawTexturedRect( self.ChatRoomMenuWidth, self.HeaderBoxHeight, 1, self.SubHeaderBoxHeight )

	surface.SetDrawColor( Color( 0, 0, 0, 50 ) )
	surface.SetTexture( self.grad_down )
	surface.DrawTexturedRect( 0, self.HeaderBoxHeight + self.SubHeaderBoxHeight + 1, w, 3 )
end

function PANEL:OnRemove()
	self.textBoxContainer:Remove()
	if ValidPanel( self.emoteContainer ) then
		self.emoteContainer:Remove()
	end
	if ValidPanel( self.settingsContainer ) then
		self.settingsContainer:Remove()
	end
	if ValidPanel( self.newRoom ) then
		self.newRoom:Remove()
	end
	if ValidPanel( self.confirmRemove ) then
		self.confirmRemove:Remove()
	end
	if ValidPanel( self.roomSett ) then
		self.roomSett:Remove()
	end
end

function PANEL:Think()

end

vgui.Register( "DFreshChatBox", PANEL )