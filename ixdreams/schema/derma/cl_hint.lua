local PANEL = {}

function PANEL:Init()

	-- if not self.text then
		-- self.text = self:Add("DLabel")
	-- end
	
	self:SetSize(500, 200)
	self:SetZPos(990)
	self:SetWrap(true)
	self:Center()
	-- self:SetDrawBackground(false)
	-- self:SetAlpha(0)
	self.background = nil
	self.fontColor = color_white
	self:SetFont("DefaultFixedDropShadow")
	-- self:SetPaintedManually(true)
end

function PANEL:SetBackground(material)
	self.background = material
end

function PANEL:GetBackground()
	return self.background
end

function PANEL:Paint(w, h)	
	-- cam.Start2D()
		-- if self.background then
			-- surface.SetMaterial(self.background)
			-- surface.SetDrawColor(255, 255, 255, 255)
			-- surface.DrawTexturedRect(0, 0, w, h)
		-- else
			-- surface.SetDrawColor(80, 80, 80, 150)
			-- surface.DrawRect(0, 0, w, h)
		-- end
		
		-- draw.DrawText(self:GetText(), "DermaDefault", w/2, h/2, self.fontColor, TEXT_ALIGN_CENTER)
	-- cam.End2D()
		derma:SkinFunc("PaintWorldHint", self, self:GetWide(), self:GetTall(), self:GetFont(), self:GetBackground())
end

vgui.Register("ixHint", PANEL, "DLabel")