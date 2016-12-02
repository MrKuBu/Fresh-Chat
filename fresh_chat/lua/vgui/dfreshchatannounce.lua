
local PANEL = {}

function PANEL:Init()
	self.bgColor = Color( 0, 0, 0, 0 )
end

function PANEL:SetBGColor( col )
	self.bgColor = col
end

function PANEL:SetChatInfo( message )
	self.chattext = vgui.Create( "DFreshChatText", self )
	self.chattext:SetPos( 8, 10 )
	self.chattext:SetWidth( self:GetWide()-(60) )
	self.chattext:SetText( "freshChat.ChatFont", message )
	self:SetHeight( self.chattext:GetTall() + 10 + 10 )
end

function PANEL:SetShadows( bool )
	self.chattext.preview = bool
	self.preview = bool
end

function PANEL:Paint( w, h )
	if not self.preview then
		draw.RoundedBox( 0, 0, 0, w, h, self.bgColor )
		draw.RoundedBox( 0, 0, h-1, w, 1, Color(0,0,0,30) )
	end
end

function PANEL:Think()
	
end

vgui.Register( "DFreshChatAnnounce", PANEL )