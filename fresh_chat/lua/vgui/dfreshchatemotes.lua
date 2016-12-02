local PANEL = {}

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

local cos, sin, rad = math.cos, math.sin, math.rad

surface.CreateFont("freshChat.MarlettSymbolsEmote", { font = "Marlett", size = 14, symbol = true })
surface.CreateFont("freshChat.MarlettCloseButton", { font = "Marlett", size = 10, symbol = true })
surface.CreateFont("freshChat.EmotePageButton", { font = "Roboto", size = 14, weight = 2000 })
surface.CreateFont("freshChat.EmoteTitle", { font = "Roboto", size = 22, weight = 200 })

function PANEL:Init()
	self:SetSize( 280, 220 )
	self.page = 1
	self.amountOnPage = 65
	self.pageCount = math.ceil(#freshChat['config']['emotes'] / self.amountOnPage)

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

	self.pagePrev = vgui.Create( "DButton", self)
	self.pagePrev:SetPos( 20, self:GetTall() - 30 )
	self.pagePrev:SetSize( 70, 30 )
	self.pagePrev:SetText("")
	self.pagePrev:SetDrawBackground(false)
	self.pagePrev.Paint = function( s, w, h )
		draw.RoundedBoxEx( 2, 0, 0, w, h, Color(108,181,244), false, false, true, false )
		draw.SimpleText( "3", "freshChat.MarlettSymbolsEmote", 20, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		draw.SimpleText( "PREV", "freshChat.EmotePageButton", w/2+5, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	self.pagePrev.DoClick = function()
		self.page = math.max( self.page - 1, 1 )
		self:SetPage( self.page )
	end

	self.pageNext = vgui.Create( "DButton", self)
	self.pageNext:SetPos( self:GetWide()-70, self:GetTall() - 30 )
	self.pageNext:SetSize( 70, 30 )
	self.pageNext:SetText("")
	self.pageNext:SetDrawBackground(false)
	self.pageNext.Paint = function( s, w, h )
		draw.RoundedBoxEx( 2, 0, 0, w, h, Color(108,181,244), false, false, false, true )
		draw.SimpleText( "4", "freshChat.MarlettSymbolsEmote", w-20, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		draw.SimpleText( "NEXT", "freshChat.EmotePageButton", w/2-5, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	self.pageNext.DoClick = function()
		self.page = math.min( self.page + 1, self.pageCount-1 )
		self:SetPage( self.page )
	end


	local wid = self:GetWide() - ( self.pagePrev:GetWide() + self.pageNext:GetWide() + 20 )
	self.curPageContainer = VGUIRect( 20 + self.pagePrev:GetWide(), self:GetTall() - 30, wid, 30 )
	self.curPageContainer:SetParent( self )
	self.curPageContainer.Paint = function( s, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color(94,98,109))
		local totalLen = (self.pageCount*8 + 2)
		draw.RoundedBox( 0, (w*0.5)-(totalLen*0.5), h*0.5, totalLen, 1, Color(159,159,159))
	end

	self:SetPage( self.page )
	self:CreatePageShorcuts()
end

function PANEL:CreatePageShorcuts()
	local p = self.curPageContainer
	local count = self.pageCount

	local totalLen = (count*9 + 2)
	local startX = (p:GetWide() * 0.5) - (totalLen * 0.5)

	local lastPageBtn = nil
	for i = 1, count do
		local pageBtn = vgui.Create( "DButton", p)
		pageBtn:SetPos( startX, p:GetTall()*0.5 - 4 )
		pageBtn:SetSize( 9, 9 )
		pageBtn:SetText("")
		pageBtn:SetDrawBackground(false)
		pageBtn.Paint = function( s, w, h )
			local outer = outer or self:CreateCircle( w, h )

			surface.SetDrawColor( Color(159,159,159) )
			draw.NoTexture()
			surface.DrawPoly( outer )

			local inner = inner or self:CreateCircle( w-4, h-4, 2 )
			local col = i == self.page and color_white or Color(94,98,109)

			surface.SetDrawColor( col )
			draw.NoTexture()
			surface.DrawPoly( inner )
		end
		pageBtn.DoClick = function()
			self.page = i
			self:SetPage( self.page )
		end

		if lastPageBtn then
			pageBtn:MoveRightOf( lastPageBtn, 2 )
		end

		lastPageBtn = pageBtn
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

function PANEL:SetPage( page )
	if ValidPanel( self.grid ) then
		self.grid:Remove()
	end

	self.grid = vgui.Create("DGrid", self)
	self.grid:SetCols( 11 )
	self.grid:SetColWide( 20 )
	self.grid:SetRowHeight( 20 )
	self.grid:SetPos( 40, 50 )

	local starting = math.max((page-1) * self.amountOnPage, 1)
	local ending = math.min(starting + self.amountOnPage, #freshChat['config']['emotes'])
	for i = starting, ending do
		local isURL = isstring(freshChat['config']['emotes'][i][2])
		local htmlIcon

		if isURL then
			htmlIcon = vgui.Create("DFreshChatHTMLIcon", icon)
			htmlIcon:SetImageSize( 16, 16 )
			htmlIcon:SetPos( 0, 0 )
			htmlIcon:SetImage( freshChat['config']['emotes'][i][2] )
		end

		local icon = vgui.Create( "DButton", isURL and htmlIcon or self )
		icon:SetSize( 16, 16 )
		icon:SetText("")
		icon.Paint = function( s, w, h )
			if not isURL then
				surface.SetDrawColor( color_white )
				surface.SetMaterial( freshChat['config']['emotes'][i][2] )
				surface.DrawTexturedRect( 0, 0, w, h )
			end
		end
		icon.DoClick = function()
			local t = freshChat['config']['emotes'][i][1]
			local old = self.mainwindow.textEntry:GetValue()
			self.mainwindow.textEntry:SetValue( old .. " " .. t .. " " )
		end

		self.grid:AddItem( isURL and htmlIcon or icon )
	end

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

	draw.SimpleText( "Emoticons", "freshChat.EmoteTitle", 40, 25, Color(0,0,0,240), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
end

function PANEL:Think()

end

vgui.Register( "DFreshChatEmotes", PANEL )