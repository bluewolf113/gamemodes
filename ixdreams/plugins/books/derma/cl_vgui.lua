local PANEL = {}

function PANEL:Init()
    self:SetSize(500, 700)
    self:MakePopup()
    self:Center()
    self:SetTitle("")
    self:ShowCloseButton(false)

    self.page = 1
    self.pages = {}

    -- Custom background
    self.Paint = function(s, w, h)
        -- White page background
        draw.RoundedBox(12, 0, 0, w, h, Color(255, 255, 255, 255))
        -- Footer / desk area (light black strip at bottom)
        draw.RoundedBox(0, 0, h - 40, w, 40, Color(235, 225, 210, 240))
        -- Title text (optional, can be set dynamically)
        draw.SimpleText(self.itemName or "", "Trebuchet24", 15, 10, Color(10, 10, 10), TEXT_ALIGN_LEFT)
    end

     -- Text box in the center
    self.contents = self:Add("DTextEntry")
    self.contents:Dock(FILL)
    self.contents:SetMultiline(true)
    self.contents:SetEditable(false)
    self.contents:DockMargin(15, 40, 15, 50)
    self.contents:SetFont("Trebuchet18")
    -- Black text on white background
    self.contents:SetTextColor(Color(10, 10, 10))
    self.contents:SetDrawBackground(false)
    self.contents:SetHighlightColor(Color(100, 150, 255))

    -- Bottom controls
    self.controls = self:Add("DPanel")
    self.controls:Dock(BOTTOM)
    self.controls:SetTall(40)
    self.controls.Paint = function(s, w, h) end

    self.confirm = self.controls:Add("DButton")
	self.confirm:Dock(RIGHT)
	self.confirm:SetWide(50)              -- narrower
	self.confirm:SetTall(24)              -- shorter height
	self.confirm:DockMargin(0, 18, 8, 8)   -- add some margin so it’s centered in the 40px bar
	self.confirm:SetText("Close")

	self.confirm.DoClick = function()
    	netstream.Start("bookSendText", self.itemID, self.pages)
    	self:Close()
	end

self.confirm.Paint = function(s, w, h)
    draw.RoundedBox(6, 0, 0, w, h, s:IsHovered() and Color(200, 60, 60) or Color(180, 50, 50))
    draw.SimpleText("Close", "Trebuchet18", w/2, h/2, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

    -- External page buttons
    self.leftArrow = vgui.Create("DButton")
    self.leftArrow:SetText("")
    self.leftArrow:SetSize(40, 60)
    self.leftArrow.DoClick = function()
        if self.page > 1 then
            self.page = self.page - 1
            self:UpdatePage()
        end
    end
    self.leftArrow.Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, s:IsHovered() and Color(70, 70, 90) or Color(50, 50, 70))
        draw.SimpleText("<", "Trebuchet24", w/2, h/2, Color(230,230,240), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    self.rightArrow = vgui.Create("DButton")
    self.rightArrow:SetText("")
    self.rightArrow:SetSize(40, 60)
    self.rightArrow.DoClick = function()
        if self.page < #self.pages then
            self.page = self.page + 1
            self:UpdatePage()
        end
    end
    self.rightArrow.Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, s:IsHovered() and Color(70, 70, 90) or Color(50, 50, 70))
        draw.SimpleText(">", "Trebuchet24", w/2, h/2, Color(230,230,240), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    -- Page indicator
    self.pageLabel = self.controls:Add("DLabel")
    self.pageLabel:Dock(FILL)
    self.pageLabel:SetContentAlignment(2)
    self.pageLabel:SetFont("Trebuchet18")
    self.pageLabel:SetTextColor(Color(10, 10, 10))
end

function PANEL:PositionArrows()
    local x, y = self:GetPos()
    local w, h = self:GetSize()

    self.leftArrow:SetPos(x - 50, y + h/2 - 30)
    self.rightArrow:SetPos(x + w + 10, y + h/2 - 30)
end

function PANEL:Think()
    if IsValid(self.leftArrow) and IsValid(self.rightArrow) then
        self:PositionArrows()
    end
end

function PANEL:OnRemove()
    if IsValid(self.leftArrow) then self.leftArrow:Remove() end
    if IsValid(self.rightArrow) then self.rightArrow:Remove() end
end

function PANEL:setText(pages, id)
    self.itemID = id
    self.pages = pages or {}
    self.page = 1
    self:UpdatePage()
end

function PANEL:UpdatePage()
    self.contents:SetValue(self.pages[self.page] or "[Blank Page]")
    if IsValid(self.pageLabel) then
        self.pageLabel:SetText("Page " .. self.page .. " / " .. math.max(#self.pages,1))
    end

    -- Play page turn sound
    surface.PlaySound("terranova/ui/notification_citizen.mp3")
end

vgui.Register("bookRead", PANEL, "DFrame")
