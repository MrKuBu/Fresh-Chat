local PANEL = {}

PANEL.visibleMsgs = {}

function PANEL:Init()
	self:SetSize( freshChat['config']['width'] - 200, freshChat['config']['height'] )
end

function PANEL:AddMessage( tChat, dead, ply, message ) 
	local chatText
	if ply == "ANNOUNCEMENT" then
		chatText = vgui.Create("DFreshChatAnnounce", self)
		chatText:SetSize( self:GetWide(), 50 )
		chatText:SetChatInfo( message )
	else
		chatText = vgui.Create("DFreshChatMessage", self)
		chatText:SetSize( self:GetWide(), 50 )
		chatText:SetPlayer( ply )
		chatText:SetChatInfo( tChat, dead, message )
	end
	
	chatText:SetPos( 0, self:GetTall()-chatText:GetTall() )
	chatText:SetShadows( true )
	self:FixPositions( chatText:GetTall(), chatText )

	table.insert(self.visibleMsgs, chatText)
	self:RemovePanelAfter( chatText )
end

function PANEL:RemovePanelAfter( pnl )
	timer.Simple( freshChat['config']['chatPreviewDuration'], function()
		if ValidPanel( pnl ) then
			pnl:AlphaTo( 0, 1, 0, function( anim, _pnl )
				_pnl:Remove()
				table.RemoveByValue(self.visibleMsgs, _pnl)
			end)
		end
	end)
end

function PANEL:FixPositions( offset, newPnl )
	for _, pnl in pairs(self.visibleMsgs)do
		if ValidPanel(pnl) and pnl != newPnl then
			local x, y = pnl:GetPos()
			pnl:MoveTo( x, y - offset, 0.2, 0, 8 )
		end
	end
end

function PANEL:Paint( w, h )
	//draw.RoundedBox( 0, 0, 0, w, h, Color(0,0,0,100) )
end

function PANEL:Think()

end

vgui.Register( "DFreshChatNotifications", PANEL )