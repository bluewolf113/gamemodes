
FACTION.name = "Citizen"
FACTION.description = "A regular human citizen enslaved by the Universal Union."
FACTION.color = Color(150, 125, 100, 255)
FACTION.isDefault = true

function FACTION:OnCharacterCreated(client, character)
    -- Generate a random CID formatted as "00-000-00"
    local id = string.format("%02d-%03d-%02d", math.random(0, 99), math.random(0, 999), math.random(0, 99))
    local inventory = character:GetInventory()

    -- Store the CID in character data
    character:SetData("cid", id)

    -- Define possible suitcase types
    local suitcaseTypes = {"suitcase", "suitcase2", "suitcase3"}
    
    -- Select a random suitcase type
    local chosenSuitcase = suitcaseTypes[math.random(#suitcaseTypes)]

    -- Add the randomly selected suitcase to inventory
    inventory:Add(chosenSuitcase, 1)

    -- Add the CID card
    inventory:Add("cid", 1, {
        name = character:GetName(),
        id = id
    })
end


FACTION_CITIZEN = FACTION.index
