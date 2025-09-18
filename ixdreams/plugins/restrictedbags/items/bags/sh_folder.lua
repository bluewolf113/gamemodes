ITEM.name = "Folder"
ITEM.description = "A bag that only accepts mugs."
ITEM.model = "models/props_c17/FurnitureFridge001a.mdl"
ITEM.width = 2
ITEM.height = 2
ITEM.invWidth = 3
ITEM.invHeight = 3

ITEM.allowedItems = {
    paper = true,
    scrappaper = true
}

function ITEM:OnInstanced(invID, x, y)
    local inventory = ix.item.inventories[invID]

    ix.inventory.New(
        inventory and inventory.owner or 0,
        self.uniqueID,
        function(inv)
            local client = inv:GetOwner()
            inv.vars.isBag = self.uniqueID
            inv.vars.allowedItems = self.allowedItems
            self:SetData("id", inv:GetID())

            if IsValid(client) then
                inv:AddReceiver(client)
            end
        end
    )
end

function ITEM:PopulateTooltip(tooltip)
    -- Allowed items list
    if self.allowedItems and table.Count(self.allowedItems) > 0 then
        local allowedList = {}

        for uniqueID, _ in pairs(self.allowedItems) do
            local itemTable = ix.item.list[uniqueID]
            if itemTable then
                table.insert(allowedList, itemTable.name or uniqueID)
            else
                table.insert(allowedList, uniqueID)
            end
        end

        local allowedPanel = tooltip:AddRow("alloweditems")
        allowedPanel:SetText("Can store: " .. table.concat(allowedList, ", "))
        allowedPanel:SetBackgroundColor(Color(200, 255, 200)) -- Light green
        allowedPanel:SizeToContents()
    end
end