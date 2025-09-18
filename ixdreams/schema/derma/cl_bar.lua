
-- bar manager
-- this manages positions for bar panels
local PANEL = {}

AccessorFunc(PANEL, "padding", "Padding", FORCE_NUMBER)

local BAR_HEIGHT = 15
local COLOR_GREY = Color(150, 150, 150, 100)

function PANEL:Init()
	self:SetSize(ScrW() * 0.15, ScrH())
	self:SetPos(4, 4)
	self:ParentToHUD()

	self.bars = {}
	self.padding = 8

	-- add bars that were registered before manager creation
	for _, v in ipairs(ix.bar.list) do
		v.panel = self:AddBar(v.index, v.color, v.priority, v.icon)
		
	end
end

function PANEL:GetAll()
	return self.bars
end

function PANEL:Clear()
	for k, v in ipairs(self.bars) do
		v:Remove()

		table.remove(self.bars, k)
	end
end

function PANEL:AddBar(index, color, priority, icon)
	local panel = self:Add("ixInfoBar")
	panel:SetSize(self:GetWide(), BAR_HEIGHT)
	panel:SetVisible(false)
	panel:SetID(index)
	panel:SetColor(color)
	panel:SetPriority(priority)
	panel:SetIconImage(icon)

	self.bars[#self.bars + 1] = panel
	self:Sort()

	return panel
end

function PANEL:RemoveBar(panel)
	local toRemove
	
	if not panel or not IsValid(panel) then return end

	for k, v in ipairs(self.bars) do
		if (v == panel) then
			toRemove = k
			break
		end
	end

	if (toRemove) then
		table.remove(self.bars, toRemove)

		-- Decrease index value for the next bars
		for i = toRemove, #self.bars do
			-- print("PANEL:RemoveBar: i = " .. tostring(i))
			-- print("PANEL:RemoveBar: priority = " .. tostring(bar.priority))
			-- print("PANEL:RemoveBar: index = " .. tostring(bar.index))
			ix.bar.list[i].index = i
			self.bars[i]:SetID(i)
		end
	end

	panel:Remove()
	self:Sort()
	
	for _, v in pairs(self.bars) do
	end
	
	for _, v in pairs(ix.bar.list) do
	end
end

-- sort bars by priority
function PANEL:Sort()
	table.sort(self.bars, function(a, b)
		return a:GetPriority() < b:GetPriority()
	end)
end

-- update target Y positions
function PANEL:Organize()
	local currentY = 0

	for _, v in ipairs(self.bars) do
		if (!v:IsVisible()) then
			continue
		end

		v:SetPos(0, currentY)

		currentY = currentY + self.padding + v:GetTall()
	end

	self:SetSize(self:GetWide(), currentY)
end

function PANEL:Think()
	local menu = (IsValid(ix.gui.characterMenu) and !ix.gui.characterMenu:IsClosing()) and ix.gui.characterMenu
		or IsValid(ix.gui.menu) and ix.gui.menu
	local fraction = menu and 1 - menu.currentAlpha / 255 or 1

	self:SetAlpha(255 * fraction)

	-- don't update bars when not visible
	if (fraction == 0) then
		return
	end

	local curTime = CurTime()
	local bShouldHide = hook.Run("ShouldHideBars")
	local bAlwaysShow = ix.option.Get("alwaysShowBars", false)

	for _, v in ipairs(self.bars) do
		local info = ix.bar.list[v:GetID()]
		local realValue, barText = info.GetValue()

		if (bShouldHide or realValue == false) then
			v:SetVisible(false)
			continue
		end

		if (v:GetDelta() != realValue) then
			v:SetLifetime(curTime + 5)
		end

		if (v:GetLifetime() < curTime and !info.visible and !bAlwaysShow and !hook.Run("ShouldBarDraw", info)) then
			v:SetVisible(false)
			continue
		end

		v:SetVisible(true)
		v:SetValue(realValue)
		v:SetText(isstring(barText) and barText or "")
	end

	self:Organize()
end

function PANEL:OnRemove()
	self:Clear()
end

vgui.Register("ixInfoBarManager", PANEL, "Panel")

PANEL = {}

AccessorFunc(PANEL, "index", "ID", FORCE_NUMBER)
AccessorFunc(PANEL, "color", "Color")
AccessorFunc(PANEL, "priority", "Priority", FORCE_NUMBER)
AccessorFunc(PANEL, "value", "Value", FORCE_NUMBER)
AccessorFunc(PANEL, "delta", "Delta", FORCE_NUMBER)
AccessorFunc(PANEL, "lifetime", "Lifetime", FORCE_NUMBER)
AccessorFunc(PANEL, "iconImage", "IconImage", FORCE_STRING)

function PANEL:Init()
	self.value = 0
	self.delta = 0
	self.lifetime = 0
	
	self:NoClipping(false)
	
	
	
	self.icon = self:Add("DImage")
	self.icon:NoClipping(false)
	self.icon:SetPaintedManually(true)
	self.icon:SetSize(BAR_HEIGHT, BAR_HEIGHT)

	-- self.icon:SetContentAlignment(4)
	-- self.icon:Dock(LEFT)
	-- self.icon:DockPadding(0, 0, 8, 0)

	self.bar = self:Add("DPanel")
	self.bar:SetPaintedManually(true)
	self.bar:Dock(FILL)
	self.bar:DockMargin(18, 2, 2, 2)
	self.bar.Paint = function(this, width, height)
		width = width * math.min(self.delta, 1)

		derma.SkinFunc("PaintInfoBar", self, width, height, self.color)
	end

	self.label = self:Add("DLabel")
	self.label:SetFont("ixSmallFont")
	self.label:SetContentAlignment(5)
	self.label:SetText("")
	self.label:SetTextColor(Color(240, 240, 240))
	self.label:SetExpensiveShadow(2, Color(20, 20, 20))
	self.label:SetPaintedManually(true)
	self.label:SizeToContents()
	self.label:Dock(FILL)
end

function PANEL:SetText(text)
	self.label:SetText(text)
	self.label:SizeToContents()
end

function PANEL:Think()
	self.delta = math.Approach(self.delta, self.value, FrameTime())
end

function PANEL:Paint(width, height)
	derma.SkinFunc("PaintInfoBarBackground", self, width, height)
	self.icon:SetImage(self:GetIconImage())
	self.icon:SetImageColor(self:GetValue() > 0 and self:GetColor() or COLOR_GREY)
	
	self.icon:PaintManual(true)
end

vgui.Register("ixInfoBar", PANEL, "Panel")

if (IsValid(ix.gui.bars)) then
	ix.gui.bars:Remove()
	ix.gui.bars = vgui.Create("ixInfoBarManager")
end
