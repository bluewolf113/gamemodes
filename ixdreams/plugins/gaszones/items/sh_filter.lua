ITEM.name = "GP-25 Filter Canister"
ITEM.description = "A high-capacity Soviet-style filter designed for extended exposure in toxic environments."
ITEM.model = "models/props_lab/reciever01b.mdl"
ITEM.category = "Testing"
ITEM.width = 1
ITEM.height = 1
ITEM.isGasmaskFilter = true
ITEM.maxDurability = 250

-- Initialize durability on creation
function ITEM:OnInstanced()
	self:SetData("durability", self.maxDurability)
end

-- Accessor
function ITEM:GetDurability()
	return self:GetData("durability", self.maxDurability)
end

-- Mutator
function ITEM:SetDurability(amount)
	self:SetData("durability", math.Clamp(amount, 0, self.maxDurability))
end

-- Tooltip
if CLIENT then
	function ITEM:PopulateTooltip(tooltip)
		local durability = self:GetDurability()
		local percent = math.ceil((durability / self.maxDurability) * 100)

		local row = tooltip:AddRow("filterStatus")
		row:SetText("Integrity: " .. percent .. "% (" .. durability .. "/" .. self.maxDurability .. ")")
		row:SetBackgroundColor(Color(100, 200, 255)) -- light blue
		row:SizeToContents()
	end
end

