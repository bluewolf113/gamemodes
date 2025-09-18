--[[
	© 2020 TERRANOVA do not share, re-distribute or modify
	without permission of its author.
--]]

CLASS.name = "Enslaved Vortigaunt"
CLASS.color = Color(0, 255, 200, 255)
CLASS.faction = FACTION_VORT
CLASS.isDefault = false

function CLASS:CanSwitchTo(client)
	return false
end

function CLASS:OnSet(client)
    timer.Simple(0, function()
        if not IsValid(client) then return end

        local removeList = {
            ["ix_nightvision"] = true,
            ["ix_vortheal"]  = true,
            ["ix_vortbeam"]  = true
        }

        for _, wep in ipairs(client:GetWeapons()) do
            local class = wep:GetClass()
            if removeList[class] then
                client:StripWeapon(class)
            end
        end
    end)

    local character = client:GetCharacter()
    if character then
        character:SetModel("models/vortigaunt_slave.mdl")
    end
end

-- Runs every time the player spawns while in this class
function CLASS:OnSpawn(client)
    timer.Simple(0, function()
        if not IsValid(client) then return end

        local removeList = {
            ["ix_nightvision"] = true,
            ["ix_vortheal"]    = true,
            ["ix_vortbeam"]    = true
        }

        for _, wep in ipairs(client:GetWeapons()) do
            if removeList[wep:GetClass()] then
                client:StripWeapon(wep:GetClass())
            end
        end
    end)

    local character = client:GetCharacter()
    if character then
        character:SetModel("models/vortigaunt_slave.mdl")
    end
end

CLASS_BIOTIC = CLASS.index