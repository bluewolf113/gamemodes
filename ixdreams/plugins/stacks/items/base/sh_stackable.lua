
ITEM.name = 'Stackable Items Base'
ITEM.description = 'Stackable Item'
ITEM.category = 'Stackable'
ITEM.model = 'models/props_c17/TrapPropeller_Lever.mdl'
ITEM.maxStacks = 16
ITEM.stackName = ""

if CLIENT then
	function ITEM:PaintOver(item, w, h)
		draw.SimpleText(
			item:GetData('stacks', 1), 'DermaDefault', w - 5, h - 5,
			color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 1, color_black
		)
	end
end

ITEM.functions.combine = {
	OnRun = function(firstItem, data)
        local firstItemStacks = firstItem:GetData('stacks', 1)
        local secondItem = ix.item.instances[data[1]]
        local secondItemStacks = secondItem:GetData('stacks', 1)
		local totalStacks = secondItemStacks + firstItemStacks

        if (firstItem.uniqueID ~= secondItem.uniqueID) then return false end
        if (totalStacks > firstItem.maxStacks) then return false end

		firstItem:SetData('stacks', totalStacks, ix.inventory.Get(firstItem.invID):GetReceivers())
		secondItem:Remove()

		return false
	end,
	OnCanRun = function(firstItem, data)
		return true
	end
}

ITEM.functions.split = {
    name = "Split",
    icon = "icon16/arrow_divide.png",
    isMulti = true,

    multiOptions = function(item, client)
        local stackCount = item:GetData("stacks", 1)
        local options = {}

        -- Show only valid split amounts
        for _, amount in ipairs({1, 5, 10, 20, 50}) do
            if amount < stackCount then
                options[#options + 1] = {
                    name = "Split " .. amount,
                    data = { amount = amount } -- MUST be a table
                }
            end
        end

        return options
    end,

    OnRun = function(item, data)
        local client = item.player
        local char = IsValid(client) and client:GetCharacter()
        if not char then return false end

        -- Accept both { amount = X } and { X } just in case
        local splitAmount = tonumber(data and (data.amount or data[1]))
        local currentStacks = item:GetData("stacks", 1)

        if not splitAmount or splitAmount <= 0 or splitAmount >= currentStacks then
            if IsValid(client) then client:Notify("Invalid split amount.") end
            return false
        end

        local newStacks = currentStacks - splitAmount
        local itemID = item.uniqueID

        -- Try to add the split stack to inventory; if full, spawn at player
        if not char:GetInventory():Add(itemID, 1, { stacks = splitAmount }) then
            ix.item.Spawn(itemID, client, nil, angle_zero, { stacks = splitAmount })
        end

        item:SetData("nextSplit", CurTime() + 1)
        item:SetData("stacks", newStacks, ix.inventory.Get(item.invID):GetReceivers())

        return false
    end,

    OnCanRun = function(item)
        return item:GetData("stacks", 1) > 1
            and item:GetData("nextSplit", 0) < CurTime()
    end
}

