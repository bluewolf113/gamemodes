ITEM.name = "8-Round 9x18mm Magazine"
ITEM.description = "A standard 8-round magazine compatible with Makarov pistols."
ITEM.model = "models/props_interiors/pot01a.mdl"
ITEM.category = "Ammunition"
ITEM.width = 1
ITEM.height = 1
ITEM.maxAmmo = 8

-- Default ammo count for a fresh mag
function ITEM:OnInstanced(invID, x, y)
    if self:GetData("rounds") == nil then
        self:SetData("rounds", self.maxAmmo)
    end
end

-- Always read ammo from instance data
function ITEM:GetAmmoStatus()
    local count = self:GetData("rounds", self.maxAmmo)
    return tostring(count) .. " / " .. self.maxAmmo .. " rounds"
end

if CLIENT then
    function ITEM:PopulateTooltip(tooltip)
        local row = tooltip:AddRow("ammoStatus")
        row:SetText("Magazine Status: " .. self:GetAmmoStatus())
        row:SetBackgroundColor(Color(200, 255, 200))
        row:SizeToContents()
    end
end