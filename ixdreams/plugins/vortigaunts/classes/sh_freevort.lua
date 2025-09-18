--[[
	© 2020 TERRANOVA do not share, re-distribute or modify
	without permission of its author.
--]]

CLASS.name = "Free Vortigaunt"
CLASS.color = Color(0, 255, 0, 255);
CLASS.faction = FACTION_VORT
CLASS.isDefault = true

function CLASS:CanSwitchTo(client)
	return false
end

function CLASS:OnSet(client)
    timer.Simple(0, function()
        if not IsValid(client) then return end

        local giveList = {
            "ix_vortheal",
            "ix_vortbeam",
			"ix_nightvision"
        }

        for _, wep in ipairs(giveList) do
            if not client:HasWeapon(wep) then
                client:Give(wep)
            end
        end
    end)

    local character = client:GetCharacter()
    if character then
        character:SetModel("models/vortigaunt.mdl")
    end
end

CLASS_FREEVORT = CLASS.index