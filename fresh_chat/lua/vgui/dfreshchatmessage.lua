
local PANEL = {}

surface.CreateFont("freshChat.ChatPlayerName", { font = "Roboto", size = 12, weight = 2000 })
surface.CreateFont("freshChat.ChatTimeStamp", { font = "Roboto", size = 11 })
surface.CreateFont("freshChat.ChatPlayerTag", { font = "Roboto", size = 13, weight = 2000 })

surface.CreateFont("freshChat.ChatRemoveButtonX", { font = "Marlett", size = 10, symbol = true})

function PANEL:Init()
	self.bgColor = color_white
	chat.PlaySound()
end

function PANEL:SetPlayer( id )
	local w, h = self:GetSize()
	self.preview = false

	self.leftMargin = 0

	if GetConVarNumber("freshchat_avatar") == 1 then
		self.leftMargin = 40
		self.avatar = vgui.Create( "DCircleAvatarMask", self)
		self.avatar:SetPos( 10, 10 )
		self.avatar:SetSize( 32, 32 )
		self.avatar:SetPlayer( id, 32 )
		self.avatar:SetMaskSize( 16 )
	end

	local tag = freshChat['config']['chatTags'](freshChat.getPlayer( id ))
	surface.SetFont("freshChat.ChatPlayerTag")
	local ww, hh = surface.GetTextSize( tag )

	self.tag = vgui.Create( "DLabel", self)
	self.tag:SetPos( 10 + self.leftMargin, 10 )
	self.tag:SetSize( ww+2, hh )
	self.tag:SetText("")
	self.tag:SetFont("freshChat.ChatPlayerTag")
	self.tag.Paint = function( s, w, h )
		local col = self.preview and color_white or Color(0,0,0,190)
		if self.preview and GetConVarNumber("freshchat_fpsmode") == 0 then
			draw.SimpleTextOutlined( tag, s:GetFont(), 0, 0, Color(0,0,0,0), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 1, Color(0,0,0,60) )
			draw.SimpleTextOutlined( tag, s:GetFont(), 0, 0, Color(0,0,0,0), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 2, Color(0,0,0,30) )
		end
		draw.SimpleText( tag, s:GetFont(), 0, 0, col, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM )
	end

	local name = steamworks.GetPlayerName(id)
	surface.SetFont("freshChat.ChatPlayerName")
	local ww, hh = surface.GetTextSize( name )

	self.playerName = vgui.Create( "DLabel", self)
	self.playerName:SetPos( self.leftMargin + 10, 10 )
	self.playerName:SetSize( ww+2, hh )
	self.playerName:SetText("")
	self.playerName:SetFont("freshChat.ChatPlayerName")
	self.playerName.Paint = function( s, w, h )
		local col = self.preview and Color(230,230,230) or Color(0,0,0,250)
		if self.preview and GetConVarNumber("freshchat_fpsmode") == 0 then
			draw.SimpleTextOutlined( name, s:GetFont(), 0, 0, Color(0,0,0,0), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 1, Color(0,0,0,60) )
			draw.SimpleTextOutlined( name, s:GetFont(), 0, 0, Color(0,0,0,0), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 2, Color(0,0,0,30) )
		end
		draw.SimpleText( name, s:GetFont(), 0, 0, col, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM )
	end

	local offset = tag == "" and -2 or 5
	self.playerName:MoveRightOf(self.tag, offset)

	self.remove = vgui.Create( "DButton", self)
	self.remove:SetPos( 2, 2 )
	self.remove:SetSize( 10, 10 )
	self.remove:SetText("")
	self.remove.Paint = function( s, w, h )
		draw.SimpleText( "r", "freshChat.ChatRemoveButtonX", w*0.5, h*0.5, Color(210,210,210), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	self.remove.DoClick = function()
		freshChat.removeChatMessage( freshChat.CurrentRoom, id, self.message )
		self:Remove()
	end

	if GetConVarNumber("freshchat_timestamps") == 1 then
		local time = os.time()
		local timeStamp = os.date( "%I:%M %p", time )
		surface.SetFont("freshChat.ChatTimeStamp")
		local _w, _h = surface.GetTextSize( timeStamp )

		self.timeStamp = vgui.Create( "DLabel", self )
		self.timeStamp:SetPos( w - (_w + 10), 10 )
		self.timeStamp:SetSize( _w, _h )
		self.timeStamp:SetText(timeStamp)
		self.timeStamp:SetTextColor( Color( 0, 0, 0, 120 ) )
		self.timeStamp:SetFont("freshChat.ChatTimeStamp")
		self.timeStamp.Think = function(s)
			if self.preview then
				s:SetText("")
			end
		end
	end
end

function PANEL:SetBGColor( col )
	self.bgColor = col
end

function PANEL:SetShadows( bool )
	self.chattext.preview = bool
	self.preview = bool

	if bool then
		self.remove:Remove()
	end
end

function PANEL:SetChatInfo( tChat, dead, message )
	self.team = tChat
	self.message = message

	self.chattext = vgui.Create( "DFreshChatText", self )
	self.chattext:SetPos( self.leftMargin + 10, 26 )
	self.chattext:SetWidth( self:GetWide()-(60) )
	self.chattext:SetText( "freshChat.ChatFont", message )
	self:SetHeight( self.chattext:GetTall() + 26 + 10 )

	if self.team then
		surface.SetFont("freshChat.ChatPlayerTag")
		local ww, hh = surface.GetTextSize( "(TEAM)" )

		self.teamText = vgui.Create( "DLabel", self)
		self.teamText:SetPos( 50, 10 )
		self.teamText:SetSize( ww, hh )
		self.teamText:SetText("")
		self.teamText:SetFont("freshChat.ChatPlayerName")
		self.teamText.Paint = function( s, w, h )
			local col = team.GetColor(LocalPlayer():Team())
			if self.preview and GetConVarNumber("freshchat_fpsmode") == 0 then
				draw.SimpleTextOutlined( "(TEAM)", s:GetFont(), 0, 0, Color(0,0,0,0), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 1, Color(0,0,0,60) )
				draw.SimpleTextOutlined( "(TEAM)", s:GetFont(), 0, 0, Color(0,0,0,0), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 2, Color(0,0,0,30) )
			end
			draw.SimpleText( "(TEAM)", s:GetFont(), 0, 0, col, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM )
		end
		self.teamText:MoveRightOf(self.playerName, 5)
	end
end

function PANEL:Paint( w, h )
	if not self.preview then
		draw.RoundedBox( 0, 0, 0, w, h, self.bgColor )
		draw.RoundedBox( 0, 0, h-1, w, 1, Color(0,0,0,30) )
	end
end

function PANEL:Think()

end

vgui.Register( "DFreshChatMessage", PANEL )