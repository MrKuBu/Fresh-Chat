local PANEL = {}
 
function PANEL:Init()
     local w, h = self:GetSize()
 
    self.html = vgui.Create( "HTML", self)
    self.html:SetSize( w, h )
    self.html:SetPos( 0, 0 )
end
 
function PANEL:SetImageSize( w, h )
    self:SetSize( w, h )
    self.html:SetSize( w, h )
end
 
function PANEL:SetImage( strURL )
    local img = string.format([[<img src = "%s" width = "%dpx" height = "%dpx"/>]], strURL, self:GetWide(), self:GetTall())
    self.html:SetHTML( [[
            <style type="text/css">
                    html, body { overflow:hidden; }

                    * { padding: 0; margin: 0; }
            </style>

            ]] .. img )
end
 
vgui.Register( "DFreshChatHTMLIcon", PANEL )