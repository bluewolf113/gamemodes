local playerMeta = FindMetaTable("Player")

function playerMeta:HasGasmask()
    return self.ixHasGasmask == true
end

local function UpdateGasmaskStatus(client)
    local char = client:GetCharacter()
    if not char then return end

    local inv = char:GetInventory()
    if not inv then return end

    for _, item in pairs(inv:GetItems()) do
        if item.isGasmask and item:GetData("equip") and item.gasmaskFilter then
            client.ixHasGasmask = true
            return
        end
    end

    client.ixHasGasmask = false
end

hook.Add("OnItemEquipped", "ixGasmaskEquip", function(client, item)
    if item.isGasmask then
        UpdateGasmaskStatus(client)
    end
end)

hook.Add("OnItemUnequipped", "ixGasmaskUnequip", function(client, item)
    if item.isGasmask then
        UpdateGasmaskStatus(client)
    end
end)

hook.Add("PlayerLoadedCharacter", "ixGasmaskCharLoad", function(client)
    UpdateGasmaskStatus(client)
end)