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

surface.CreateFont("freshChat.SettingText", { font = "Roboto", size = 16, weight = 2000 })
surface.CreateFont("freshChat.MarlettCheck", { font = "Marlett", size = 15, symbol = true })

CreateClientConVar( "freshchat_tts", 0, true, false )
CreateClientConVar( "freshchat_avatar", 1, true, false )
CreateClientConVar( "freshchat_webemotes", 1, true, false )
CreateClientConVar( "freshchat_emotes", 1, true, false )
CreateClientConVar( "freshchat_timestamps", 1, true, false )
CreateClientConVar( "freshchat_fpsmode", 0, true, false )

CreateClientConVar( "freshchat_tts_lan", "en-us", true, false )

PANEL.settings = {
	{ "Text to Speech", "freshchat_tts" },
	{ "Draw Player Avatars", "freshchat_avatar" },
	{ "Draw Emotes", "freshchat_emotes" },
	{ "Draw Web Emotes", "freshchat_webemotes" },
	{ "Draw Time Stamps", "freshchat_timestamps" },
	{ "FPS Save", "freshchat_fpsmode" },
}

PANEL.tts_languages = {
	["en-gb"] = "English - Great Britain",
	["en-us"] = "English - United States",
	["it"] = "Italian", 
	["de-de"] = "German", 
	["ja"] = "Japanese", 
	["pl"] = "Polish", 
	["ru"] = "Russian", 
	["es"] = "Spanish", 
	["da"] = "Danish",
	["fr"] = "French", 
	["tr"] = "Turkish", 
}

function PANEL:Init()
	self:SetSize( 280, 320 )

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

	self.tts_lan = vgui.Create("DComboBox", self) 
	self.tts_lan:SetPos( 40, 50 )
	self.tts_lan:SetSize( self:GetWide()-60, 20 )
	self.tts_lan:SetValue( self.tts_languages[ GetConVarString( "freshchat_tts_lan" ) ] )
	self.tts_lan.Paint = function( s, w, h )
		draw.RoundedBox( 2, 0, 0, w, h, Color(0,0,0,90) )
		draw.RoundedBox( 2, 1, 1, w-2, h-2, color_white )
	end
	local oldOpen = self.tts_lan.OpenMenu
	self.tts_lan.OpenMenu = function(s, pControlOpener)
		oldOpen(s, pControlOpener)
		s.Menu.Paint = function( s, w, h )
			draw.RoundedBox( 4, 0, 0, w, h, Color(0,0,0,30) )
			draw.RoundedBox( 4, 1, 1, w-2, h-2, Color(0,0,0,60) )
			draw.RoundedBox( 4, 2, 2, w-4, h-4, color_white )
		end
		for _, btn in pairs(s.Menu:GetCanvas():GetChildren())do
			btn:SetTextColor(Color(0,0,0,200))
			btn.Paint = function( s, w, h )
				s:SetTextColor(Color(0,0,0,200))
				if s.Highlight or s.Hovered then
					draw.RoundedBox( 0, 2, 2, w-4, h-4, Color(108,181,244) )
					s:SetTextColor(color_white)
				end
			end
		end
	end
	self.tts_lan.OnSelect = function( index, val, data )
		local code = table.KeyFromValue( self.tts_languages, data )
		RunConsoleCommand( "freshchat_tts_lan",  code)
	end
	for code, lan in pairs(self.tts_languages)do
		-- why the fuck wont the data arg work...
		self.tts_lan:AddChoice(lan, code, false)
	end

	local lastSetBtn = nil
	for _, setting in pairs(self.settings)do
		local setBtn = vgui.Create( "DButton", self)
		setBtn:SetPos( 40, 80 )
		setBtn:SetSize( self:GetWide()-40, 20 )
		setBtn:SetText("")
		setBtn:SetDrawBackground(false)
		setBtn.active = tobool(GetConVarNumber( setting[2] ))
		setBtn.Paint = function( s, w, h )
			draw.RoundedBox( 0, 5, 5, 15, 15, Color(210, 210, 210) )
			draw.RoundedBox( 0, 6, 6, 13, 13, color_white )
			if s.active then
				draw.SimpleText( "a", "freshChat.MarlettCheck", 13, h*0.5+2, Color(120, 120, 120), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			end
			draw.SimpleText( setting[1], "freshChat.SettingText", 25, h*0.5+2, Color(120, 120, 120), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		end
		setBtn.DoClick = function(s)
			s.active = !s.active
			RunConsoleCommand( setting[2], s.active and 1 or 0 )
		end

		if lastSetBtn then
			setBtn:MoveBelow( lastSetBtn )
		end

		lastSetBtn = setBtn
	end
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
	draw.RoundedBox( 2, 20, 0, w-20, h, color_white )

	surface.SetDrawColor( Color( 210, 210, 210 ) )
	draw.NoTexture()
	surface.DrawPoly( self.triangleOutline )

	surface.SetDrawColor( color_white )
	draw.NoTexture()
	surface.DrawPoly( self.triangle )

	draw.SimpleText( "Settings", "freshChat.EmoteTitle", 40, 25, Color(0,0,0,240), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
end

function PANEL:Think()

end

vgui.Register( "DFreshChatSettings", PANEL )