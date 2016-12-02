local PANEL = {}
local cos, sin, rad = math.cos, math.sin, math.rad

PANEL.selectedPlayers = {}

surface.CreateFont("freshChat.playerName", { font = "Roboto", size = 16, weight = 2000 })

function PANEL:Init()
	self:SetSize( 280, 360 )
	self:SetPos( ScrW()*0.5 - 140, ScrH()*0.5 - 160 )

	table.HasValue( self.selectedPlayers, LocalPlayer():SteamID64() )

	self.closeBtn = vgui.Create( "DButton", self)
	self.closeBtn:SetPos( self:GetWide()-22, 8 )
	self.closeBtn:SetSize( 12, 12 )
	self.closeBtn:SetText("")
	self.closeBtn:SetDrawBackground(false)
	self.closeBtn.Paint = function( s, w, h )
		local circle = circle or self:CreateCircle( w, h )
		surface.SetDrawColor( Color( 210, 210, 210 ) )
		draw.NoTexture()
		surface.DrawPoly( circle )
		draw.SimpleText( "r", "freshChat.MarlettCloseButton", w*0.5, h*0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	self.closeBtn.DoClick = function()
		self:Remove()
	end

	local textX, textY = self:GetPos()
	self.textBoxContainer = vgui.Create( "DFrame", self )
	self.textBoxContainer:SetPos( textX + 40, textY + 50 )
	self.textBoxContainer:SetSize( self:GetWide()-60, 30 )
	self.textBoxContainer:SetDraggable(false)
	self.textBoxContainer:ShowCloseButton( false )
	self.textBoxContainer:SetTitle("")
	self.textBoxContainer.Paint = function( s, w, h ) end
	self.textBoxContainer:MakePopup()

	self.textEntry = vgui.Create( "DTextEntry", self.textBoxContainer )
	self.textEntry:SetPos( 5, 5 )
	self.textEntry:SetSize( self.textBoxContainer:GetWide()-10, self.textBoxContainer:GetTall()-10 )
	self.textEntry:SetMultiline(false)
	self.textEntry.OnLoseFocus = function(t)
		self.textBoxContainer:KillFocus()
	end
	self.textEntry:SetText("")
	self.textEntry.Paint = function( s, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color(210,210,210))
		draw.RoundedBox( 0, 1, 1, w-2, h-2, Color(255,255,255))
		s:DrawTextEntryText(Color(30, 30, 30), Color(108,181,244), Color(0, 0, 0))

		if s:GetValue() == "" then
			draw.SimpleText( "Room Name", "freshChat.TextEntryFiller", 5, h/2, Color(0,0,0,130), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		end
	end
	self.textEntry:RequestFocus()

	self.plyContainer = vgui.Create( "DScrollPanel", self)
    self.plyContainer:SetSize( self:GetWide()-60, self:GetTall()-150 )
    self.plyContainer:SetPos( 40, 90 )
	self.plyContainer.Paint = function( s, w, h )
		//draw.RoundedBox( 0, 0, 0, w, h, Color(210,0,0))
	end
    self.plyContainer.VBar:SetWidth( 1 )
	self.plyContainer.VBar.Paint = function( s, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color(255,255,255))
	end
	self.plyContainer.VBar.btnUp.Paint = function() end
	self.plyContainer.VBar.btnDown.Paint = function() end
	self.plyContainer.VBar.btnGrip.Paint = function( s, w, h )
		draw.RoundedBox( 0, 0, 0, w, h+22, Color(0,0,0,90))
	end

	self.create = vgui.Create( "DButton", self )
	self.create:SetPos( self:GetWide()*0.5 - 50 + 10, 0 )
	self.create:SetSize( 100, 30 )
	self.create:SetText("")
	self.create:SetDrawBackground(false)
	self.create.Paint = function( s, w, h )
		draw.RoundedBox( 4, 0, 0, w, h, Color(94,158,213) )
		draw.RoundedBox( 4, 1, 1, w-2, h-2, s.col )
		draw.SimpleText( "CREATE", "freshChat.playerName", w/2, h/2, s.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	self.create.Think = function( s )
		if s:IsHovered() then
			s.col = Color(94,158,213)
			s.text = color_white
		else
			s.col = color_white
			s.text = Color(94,158,213)
		end
	end
	self.create.DoClick = function( s )
		if self.textEntry:GetValue() != "" then
			net.Start("freshChat.sendNewChatRoom")
			net.WriteString(self.textEntry:GetValue())
			net.WriteTable(self.selectedPlayers)
			net.SendToServer()
			self:Remove()
		end
	end
	self.create:MoveBelow( self.plyContainer )

	local lastBtn = nil
	for _, ply in pairs(player.GetAll())do
		if ply == LocalPlayer() then continue end
		
		local btn = vgui.Create( "DButton", self.plyContainer )
		btn.active = false
		btn:SetPos( 0, 0 )
		btn:SetSize( self.plyContainer:GetWide(), 40 )
		btn:SetText("")
		btn:SetDrawBackground(false)
		btn.Paint = function( s, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, color_white )
			draw.SimpleText( ply:Nick(), "freshChat.playerName", 50, h/2, Color(0,0,0,130), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

			draw.RoundedBox( 0, w-20, h*0.5 - 7, 15, 15, Color(210, 210, 210) )
			draw.RoundedBox( 0, w-19, h*0.5 - 6, 13, 13, color_white )
			if s.active then
				draw.SimpleText( "a", "freshChat.MarlettCheck", w-13, h*0.5, Color(120, 120, 120), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			end
		end
		btn.DoClick = function( s )
			s.active = !s.active

			if s.active then
				table.insert( self.selectedPlayers, ply:SteamID64() )
			else
				table.RemoveByValue( self.selectedPlayers, ply:SteamID64() )
			end
		end

		if lastBtn then
			btn:MoveBelow( lastBtn )
		end
		lastBtn = btn

		local avatar = vgui.Create( "DCircleAvatarMask", btn )
		avatar:SetPos( 4, 4 )
		avatar:SetSize( 32, 32 )
		avatar:SetPlayer( ply:SteamID64(), 32 )
		avatar:SetMaskSize( 16 )

		self.plyContainer:AddItem( btn )
	end
end

function PANEL:SetMainWindow( pnl )
	self.mainwindow = pnl
end

function PANEL:CreateCircle( w, h, offset )
	local offset = offset or 0
	local circle, t = {}, 0
	local m = w/2
    for i = 1, 360 do
        t = rad(i)
        circle[i] = { x = w/2 + cos(t)*m + offset, y = h/2 + sin(t)*m + offset }
    end

    return circle
end

function PANEL:Paint( w, h )
	draw.RoundedBox( 2, 20, 0, w, h, color_white )

	draw.SimpleText( "Create a New Room", "freshChat.EmoteTitle", 40, 25, Color(0,0,0,240), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
end

function PANEL:Think()

end

vgui.Register( "DFreshChatRoom", PANEL )