ITEM.base = "base_rawmaterial"

ITEM.name = "Uranium Ore"
ITEM.model = "models/oldprops/ore_tin.mdl"
ITEM.description = "Chunks of rock bearing veins of raw uranium dioxide."
ITEM.rads = 25

ITEM.width = 1
ITEM.height = 1

ITEM:Hook("OnInstanced", "InitializeRadiation", function(invID, x, y, item, data)
	self:SetData("rads", rads)
end)