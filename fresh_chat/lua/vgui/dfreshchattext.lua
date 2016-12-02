-- This is going to be hell to make....

local PANEL = {}

local surface = surface
local draw = draw
local table = table

function PANEL:Init()
	self.text = ""
	self.drewText = false
	self.spaceLength = 3
	self.urlicons = {}
	self.links = {}
	self.Adjustments = {}
	self.webEmotes = 0
end

function PANEL:SetText( font, text )
	self.text = text
	self.gotText = true

	self.font = font
	self.gotFont = true

	local wid = self:GetWide()
	surface.SetFont( self.font )
	local texWid, texTall = surface.GetTextSize( self:RemoveColorStrings( text ) )

	local height = math.ceil( texWid / wid ) * 16
	self.iconFontDiff = 16 - height
	height = math.max( height, 16 )

	self:SetTall( height )

	self:CreateTextTable( text )
end

-- Remove all the color strings for height calculations
function PANEL:RemoveColorStrings( str )
	local rep, count = string.gsub( str, "@Color%[(%d+),(%d+),(%d+),(%d+)%] ", "" )
	return rep
end

function PANEL:WordHasEmote( word )
	if GetConVarNumber("freshchat_emotes") == 0 then return false end
	
	for _, emote in pairs(freshChat['config']['emotes'])do
		if emote[1] == word then
			if isstring(emote[2]) and (string.StartWith(emote[2], "http://") or string.StartWith(emote[2], "https://")) then
				if GetConVarNumber("freshchat_webemotes") == 0 then
					return false
				else
					if self.webEmotes >= freshChat['config']['webEmoteLimit'] then
						return false
					else
						self.webEmotes = self.webEmotes + 1
						return { "URLIcon", emote[2], emote[3] or 16, emote[4] or 16 }
					end
				end
			else
				return emote[2]
			end
		end
	end
end

function PANEL:WordIsBanned( word )
	if table.HasValue( freshChat['config']['wordFilterList'], string.lower( word ) ) then
		return freshChat.bannedWordString( word )
	end
end

function PANEL:WordHasColor( word )
	if string.StartWith( word,  "@Color")  then
		local c = string.Split(string.sub( word, 8, #word-1), ",")
		local col = Color(tonumber(c[1]), tonumber(c[2]), tonumber(c[3]))

		return col
	end

	for _, prefix in pairs(freshChat['config']['colors'])do
		local prefixStart, prefixEnd = string.find( word, prefix[1], 0, true )
		if prefixStart then
			local before = string.sub( word, 0, prefixStart-1 )
			local after = string.sub( word, prefixEnd+1, #word )
			return before, prefix[2], after
		end
	end
end

function PANEL:WordHasLink( word )
	if string.StartWith(word, "http://") or string.StartWith(word, "https://") then
		return { "URL", word }
	end
end

function PANEL:ScaleDownImage( width, height )
	return ( width * 16 ) / height
end

function PANEL:CreateTextTable( text )

	self.textTbl = {}

	local words = string.Explode( " ", text )
	local col = self.preview and color_white or Color(0,0,0,200)
	local newCol

	for _, word in pairs(words) do
		
		-- search the word for icons
		local icon = self:WordHasEmote( word )

		local before, after
		-- if there is no icon, look for a color change
		if not icon then
			-- check for color change and return what is before and
			-- after it
			before, newCol, after = self:WordHasColor( word )

			-- add anything before the color change string
			if before and IsColor(before) then
				newCol = before
			elseif before and before != "" then
				table.insert( self.textTbl, before )
			end

			-- add the color change
			if newCol then
				table.insert( self.textTbl, newCol )
			end

			-- insert the string after the declaration of the color
			-- change, and a space.
			if after then
				table.insert( self.textTbl, after )
				table.insert( self.textTbl, " " )
			end

		else
			-- If there is an icon, add it with a space at the end.
			table.insert( self.textTbl, icon )
			table.insert( self.textTbl, " " )
		end

		-- If there is no new color or icon, its just a regular word or a link
		-- so just add it with a space after.
		if not newCol and not icon then
			local banned = freshChat['config']['wordFiltering']
			if banned then
				banned = self:WordIsBanned( word )
			end
			local isLink = self:WordHasLink( word )
			if isLink then
				table.insert( self.textTbl, isLink )
				table.insert( self.textTbl, " " )
			elseif banned then
				table.insert( self.textTbl, banned )
				table.insert( self.textTbl, " " )
			else
				table.insert( self.textTbl, word )
				table.insert( self.textTbl, " " )
			end
		end
	end

	//print("---------------------------------------")
	//PrintTable( self.textTbl )

end

function PANEL:Paint( w, h )
	if self.textTbl then

		local currentLine = 0
		local currentLength = 0
		local col = self.preview and color_white or Color(0,0,0,200)
		
		for _, val in ipairs( self.textTbl )do

			::reset::

			local startY, startX = 16 * currentLine, currentLength

			if isstring(val) then
				surface.SetFont( self.font )
				local length = surface.GetTextSize( val )

				if length > w then
					-- boop
				elseif currentLength + length > w then
					currentLine = currentLine + 1
					currentLength = 0
					goto reset
				end

				if self.preview and GetConVarNumber("freshchat_fpsmode") == 0 then
					draw.SimpleTextOutlined( val, self.font, startX, startY, Color(0,0,0,0), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 1, Color(0,0,0,60) )
					draw.SimpleTextOutlined( val, self.font, startX, startY, Color(0,0,0,0), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 2, Color(0,0,0,30) )
				elseif col == color_white and !self.preview then
					draw.SimpleTextOutlined( val, self.font, startX, startY, Color(0,0,0,0), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 1, Color(0,0,0,60) )
				end

				-- fg text
				surface.SetFont( self.font )
				surface.SetTextColor( col )
				surface.SetTextPos( startX, startY ) 
				surface.DrawText( val )

				currentLength = currentLength + length

			elseif IsColor(val) then
				col = val

			elseif istable(val) then
				if val[1] == "URLIcon" then
					if currentLength + val[3] > w then
						currentLine = currentLine + 1
						currentLength = 0
						goto reset
					end

					local aspectWidth = self:ScaleDownImage( val[3], val[4] )
					if not table.HasValue( self.urlicons, val[2] ) then
						table.insert( self.urlicons, { val[2], currentLine, currentLength, aspectWidth, 16, val[3], val[4] } )
					end
					currentLength = currentLength + aspectWidth
				elseif val[1] == "URL" then
					surface.SetFont( self.font )
					local l = surface.GetTextSize( val[2] )

					if currentLength + l > w then
						currentLine = currentLine + 1
						currentLength = 0
						goto reset
					end

					if not table.HasValue( self.links, val[2] ) then
						table.insert( self.links, { val[2], currentLine, currentLength } )
					end
					currentLength = currentLength + l
				end


			else
				if currentLength + 16 > w then
					currentLine = currentLine + 1
					currentLength = 0
					goto reset
				end

				surface.SetDrawColor(color_white)
				surface.SetMaterial(val)
				surface.DrawTexturedRect( startX, startY, 16, 16 )

				currentLength = currentLength + 16

			end
		end
	end

	if not self.createdHTMLIcons then
		self:CreateHTMLIcons()
	end

	if not self.createdLinks then
		self:CreateLinks()
	end
end

function PANEL:CreateLinks()
	self.createdLinks = true

	for _, v in ipairs(self.links)do
		local URL, linkY, linkX = v[1], v[2]*16, v[3]
		surface.SetFont( self.font )
		local l = surface.GetTextSize( URL )

		local link = vgui.Create("DButton", self)
		link:SetSize( l, 16 )
		link:SetPos( linkX, linkY )
		link:SetText("")
		link.Paint = function( s, w, h )
			if self.preview then
				draw.SimpleTextOutlined( URL, self.font, 0, 0, Color(0,0,0,0), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 1, Color(0,0,0,60) )
				draw.SimpleTextOutlined( URL, self.font, 0, 0, Color(0,0,0,0), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 2, Color(0,0,0,30) )
			end

			draw.SimpleText( URL, self.font, 0, 0, Color(25, 181, 254), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM )
			draw.RoundedBox( 0, 0, h-5, w, 1, Color(25, 181, 254) )
		end
		link.DoClick = function()
			gui.OpenURL( URL )
		end
	end

end

function PANEL:CreateHTMLIcons()
	self.createdHTMLIcons = true

	for _, v in ipairs(self.urlicons)do
		local iconURL, iconY, iconX = v[1], v[2]*16, v[3]

		local icon = vgui.Create("DFreshChatHTMLIcon", self)
		icon:SetImageSize( v[4], v[5] )
		icon:SetPos( iconX, iconY )
		icon:SetImage( iconURL )

		local btn = vgui.Create( "DButton", icon)
		btn:SetPos( 0, 0 )
		btn:SetSize( v[4], v[5] )
		btn:SetText("")
		btn:SetDrawBackground(false)
		btn.Paint = function( s, w, h ) end
		btn.OnCursorEntered = function( s )
			local x, y = gui.MousePos()

			if not s.image and not IsValid(s.image) then
				s.image = vgui.Create("DFreshChatHTMLIcon")
				s.image:SetImageSize( v[6], v[7] )
				s.image:SetPos( x + 10, y - v[7] )
				s.image:SetImage( iconURL )
			end
		end
		btn.Think = function( s )
			local x, y = gui.MousePos()
			if s.image and IsValid(s.image) and s:IsHovered() then
				s.image:SetPos( x + 10, y - v[7] )
			end

			if s.image and IsValid(s.image) and not s:IsHovered() then
				s.image:Remove()
				s.image = nil
			end
		end
	end

end

function PANEL:Think()

end

vgui.Register( "DFreshChatText", PANEL )