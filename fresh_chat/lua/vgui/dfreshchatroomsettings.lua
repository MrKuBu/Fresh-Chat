local PANEL = {}
local cos, sin, rad = math.cos, math.sin, math.rad

PANEL.triangle = {
	{ x = 0, y = 30},
	{ x = 22, y = 20},
	{ x = 22, y = 40},
}

PANEL.triangleOutline = {
	{ x = -2, y = 30},
	{ x = 22, y = 19},
	{ x = 22, y = 41},
}

PANEL.selectedPlayers = {}

surface.CreateFont("freshChat.playerName", { font = "Roboto", size = 13, weight = 10 })
surface.CreateFont("freshChat.subTitle", { font = "Roboto", size = 18, weight = 10 })

function PANEL:Init()
	self:SetSize( 340, 290 )

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

	self.plyContainer = vgui.Create( "DScrollPanel", self)
    self.plyContainer:SetSize( 294, 170 )
    self.plyContainer:SetPos( 34, 70 )
	self.plyContainer.Paint = function( s, w, h )
		//draw.RoundedBox( 0, 0, 0, w, h, Color(210,0,0))
	end
    self.plyContainer.VBar:SetWidth( 8 )
	self.plyContainer.VBar.Paint = function( s, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color(255,255,255))
	end
	self.plyContainer.VBar.btnUp.Paint = function() end
	self.plyContainer.VBar.btnDown.Paint = function() end
	self.plyContainer.VBar.btnGrip.Paint = function( s, w, h )
		draw.RoundedBox( 0, 0, 0, w, h+22, Color(0,0,0,90))
	end

	self.playerGrid = vgui.Create("DGrid", self.plyContainer )
	self.playerGrid:SetCols( 7 )
	self.playerGrid:SetColWide( 42 )
	self.playerGrid:SetRowHeight( 42 )
	self.playerGrid:SetPos( 0, 0 )

	for _, ply in pairs(player.GetAll())do
		if ply == LocalPlayer() then continue end

		local room = freshChat.ChatRooms[freshChat.CurrentRoom]
		local hasAccess = room.ACCESS(ply) or room.CREATOR == ply
		if not hasAccess and (table.HasValue( room.LIST, ply:SteamID64() )) then
			hasAccess = true
		end

		if hasAccess then
			if not table.HasValue( self.selectedPlayers, ply:SteamID64() ) then
				table.insert( self.selectedPlayers, ply:SteamID64() )
			end
		end

		local cont = VGUIRect( 0, 0, 40, 40 )
		cont:SetColor(Color(0,0,0,0))
		cont:SetParent(self.playerGrid)
		cont.Paint = function( s, w, h )
			if cont.btn then
				draw.NoTexture()
				if cont.btn.active then
					surface.SetDrawColor( Color( 0, 255, 0 ) )
				else
					surface.SetDrawColor( Color( 255, 0, 0 ) )
				end
				surface.DrawPoly(self:CreateCircle( 40, 40, 0 ))

				draw.NoTexture()
				surface.SetDrawColor( color_white )
				surface.DrawPoly(self:CreateCircle( 36, 36, 2 ))
			end
		end

		local avatar = vgui.Create( "DCircleAvatarMask", cont )
		avatar:SetPos( 4, 4 )
		avatar:SetSize( 32, 32 )
		avatar:SetPlayer( ply:SteamID64(), 32 )
		avatar:SetMaskSize( 16 )

		local btn = vgui.Create( "DButton", cont )
		btn.active = hasAccess
		cont.btn = btn
		btn:SetPos( 0, 0  )
		btn:SetSize( 40, 40 )
		btn:SetText("")
		btn:SetDrawBackground(false)
		surface.SetFont("freshChat.playerName")
		btn.nameLength = surface.GetTextSize( ply:Nick() )
		btn.nameX = 5
		btn.LastMove = CurTime()
		btn.Paint = function( s, w, h )
			if s:IsHovered() then
				draw.RoundedBox( 0, 0, h-20, w, 20, Color(55,57,66) )
				draw.SimpleText( ply:Nick(), "freshChat.playerName", btn.nameX, h-10, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
			end
		end
		btn.Think = function( s )
			if s:IsHovered() and s.LastMove < CurTime() and btn.nameLength+5 > s:GetWide() then
				s.nameX = s.nameX - 1
				if s.nameX < -(s.nameLength + 5) then
					s.nameX = s:GetWide() + 5
				end
				s.LastMove = CurTime() + 0.02
			end
		end
		btn.DoClick = function( s )
			s.active = !s.active

			if s.active then
				if not table.HasValue( self.selectedPlayers, ply:SteamID64() ) then
					table.insert( self.selectedPlayers, ply:SteamID64() )
				end
			else
				table.RemoveByValue( self.selectedPlayers, ply:SteamID64() )
			end
		end

		self.playerGrid:AddItem( cont )
	end

	self.confirm = vgui.Create( "DButton", self )
	self.confirm:SetPos( self:GetWide()*0.5 - 50 + 10, 0 )
	self.confirm:SetSize( 100, 30 )
	self.confirm:SetText("")
	self.confirm:SetDrawBackground(false)
	self.confirm.Paint = function( s, w, h )
		draw.RoundedBox( 4, 0, 0, w, h, Color(94,158,213) )
		draw.RoundedBox( 4, 1, 1, w-2, h-2, s.col )
		draw.SimpleText( "CONFIRM", "freshChat.playerName", w/2, h/2, s.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	self.confirm.Think = function( s )
		if s:IsHovered() then
			s.col = Color(94,158,213)
			s.text = color_white
		else
			s.col = color_white
			s.text = Color(94,158,213)
		end
	end
	self.confirm.DoClick = function( s )
		net.Start("freshChat.updateChatRoomList")
		net.WriteFloat( freshChat.CurrentRoom )
		net.WriteTable( self.selectedPlayers )
		net.SendToServer()
		self:Remove()
	end
	self.confirm:MoveBelow( self.plyContainer, 10 )
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

function PANEL:SetMainWindow( pnl )
	self.mainwindow = pnl
end

function PANEL:Paint( w, h )
	draw.RoundedBox( 2, 20, 0, w-20, h, Color( 210, 210, 210 ) )
	draw.RoundedBox( 2, 21, 1, w-22, h-2, color_white )

	surface.SetDrawColor( Color( 210, 210, 210 ) )
	draw.NoTexture()
	surface.DrawPoly( self.triangleOutline )

	surface.SetDrawColor( color_white )
	draw.NoTexture()
	surface.DrawPoly( self.triangle )

	draw.SimpleText( "Room Settings", "freshChat.EmoteTitle", 40, 25, Color(0,0,0,240), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

	draw.SimpleText( "Access List", "freshChat.subTitle", 40, 45, Color(0,0,0,190), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM )
end

function PANEL:Think()

end

vgui.Register( "DFreshChatRoomSettings", PANEL )