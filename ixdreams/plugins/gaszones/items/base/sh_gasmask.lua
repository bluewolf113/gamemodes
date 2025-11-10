ITEM.name = "Gasmask"
ITEM.description = "A protective mask designed to filter toxic air."
ITEM.model = "models/willardnetworks/clothingitems/head_gasmask.mdl"
ITEM.category = "Testing"
ITEM.width = 2
ITEM.height = 2
ITEM.outfitCategory = "head"
ITEM.isGasmask = true
ITEM.gasmaskDurability = nil
ITEM.gasmaskDurabilityMax = 250

ITEM.functions.combine = {
	OnRun = function(item, data)
		local targetItem = ix.item.instances[data[1]]
		local client = item.player
		if not IsValid(client) or not targetItem then return false end

		if targetItem.isGasmaskFilter and targetItem.filterAmount then
			local maxDurability = item.gasmaskDurabilityMax or 250
			local currentDurability = item:GetData("gasmaskdurability", 0)
			local addedDurability = targetItem.filterAmount

			if currentDurability + addedDurability > maxDurability then
				client:Notify("This filter would exceed the gasmask's maximum durability.")
				return false
			end

			local newDurability = currentDurability + addedDurability
			item:SetData("gasmaskdurability", newDurability)

			local percent = math.ceil((newDurability / maxDurability) * 100)
			client:Notify("Filter attached. Durability is now " .. newDurability .. " (" .. percent .. "%).")
            targetItem:Remove()
			return false 
		end

		client:Notify("This item cannot be used as a filter.")
		return true
	end,
	OnCanRun = function(item, data)
        local targetItem = ix.item.instances[data[1]]

        -- Only allow combine if the target item is a knife
        return targetItem and targetItem.isGasmaskFilter
	end
}

if CLIENT then
	function ITEM:PopulateTooltip(tooltip)
		local durability = self:GetData("gasmaskdurability", 0)
		local max = self.gasmaskDurabilityMax or 250

		local row = tooltip:AddRow("filterStatus")

		if durability > 0 then
			local percent = math.ceil((durability / max) * 100)
			local status

			if percent >= 90 then
				status = "Pristine"
			elseif percent >= 60 then
				status = "Worn"
			elseif percent >= 30 then
				status = "Damaged"
			else
				status = "Critical"
			end

			row:SetText("Filter Status: " .. status)
			row:SetBackgroundColor(Color(100, 200, 255)) -- light blue
		else
			row:SetText("No filter installed.")
			row:SetBackgroundColor(Color(255, 100, 100)) -- light red
		end

		row:SizeToContents()
	end
end
