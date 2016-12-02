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

function PANEL:Init()
	self:SetSize( 280, 150 )

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

	self.text = vgui.Create( "DLabel", self )
	self.text:SetPos( 42, 15 )
	self.text:SetSize( self:GetWide() - 64, 100 )
	self.text:SetText( "Are you sure you want to delete this room?" )
	self.text:SetFont( "freshChat.SettingText" )
	self.text:SetColor( Color( 0, 0, 0, 160 ) )
	self.text:SetWrap( true )

	self.confirm = vgui.Create( "DButton", self)
	self.confirm:SetPos( 42, self:GetTall() - 50 )
	self.confirm:SetSize( 100, 40 )
	self.confirm:SetText("")
	self.confirm:SetDrawBackground(false)
	self.confirm.Paint = function( s, w, h )
		draw.RoundedBox( 2, 0, 0, w, h, Color( 0, 177, 106 ) )
		draw.RoundedBox( 2, 1, 1, w-2, h-2, Color( 0, 0, 0, 70 ) )
		draw.SimpleText( "CONFIRM", "freshChat.SettingText", w*0.5, h*0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	self.confirm.DoClick = function()
		self:Remove()
		freshChat.removeRoom()
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
	draw.RoundedBox( 2, 20, 0, w-20, h, Color( 210, 210, 210 ) )
	draw.RoundedBox( 2, 21, 1, w-22, h-2, color_white )

	surface.SetDrawColor( Color( 210, 210, 210 ) )
	draw.NoTexture()
	surface.DrawPoly( self.triangleOutline )

	surface.SetDrawColor( color_white )
	draw.NoTexture()
	surface.DrawPoly( self.triangle )

	draw.SimpleText( "Remove Room", "freshChat.EmoteTitle", 40, 25, Color(0,0,0,240), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
end

function PANEL:Think()

end

vgui.Register( "DFreshChatConfirm", PANEL )