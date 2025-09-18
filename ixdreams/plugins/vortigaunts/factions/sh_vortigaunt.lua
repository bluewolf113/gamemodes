--[[
	© 2020 TERRANOVA do not share, re-distribute or modify
	without permission of its author.
--]]

FACTION.name = "Vortigaunt"
FACTION.description = "Those Vortigaunts that live free. Not from this planet, and formerly resided in the Xen dimension before coming to Earth. Wise, articulate, powerful."
FACTION.color = Color(0, 255, 0, 255);
FACTION.runSounds = {[0] = "NPC_Vortigaunt.FootstepLeft", [1] = "NPC_Vortigaunt.FootstepRight"}
FACTION.weapons = {"ix_vortbeam", "ix_vortheal", "ix_nightvision"}
FACTION.walkSounds = FACTION.runSounds
FACTION.isDefault = false
FACTION.models = {
	"models/vortigaunt.mdl"
}


-- Store default speeds so we can restore them later
FACTION.defaultWalk = ix.config.Get("walkSpeed", 130)
FACTION.defaultRun  = ix.config.Get("runSpeed", 235)

function FACTION:OnSpawn(client, character)
    client:SetWalkSpeed(self.defaultWalk * 0.85)
	client:SetRunSpeed(self.defaultRun * 0.75) -- 75% slower
end

function FACTION:OnCharacterCreated(client, character)
    local langs = character:GetData("languages", {})
    langs["Vortigese"] = true
    character:SetData("languages", langs)
end

function FACTION:OnTransferred(client)
    local character = client:GetCharacter()
    character:SetModel(self.models[1])

    -- Apply slower walk speed when transferred into this faction
    client:SetWalkSpeed(self.defaultWalk * 0.85)
	client:SetRunSpeed(self.defaultRun * 0.75)
end

-- When they leave this faction, restore normal speeds
function FACTION:OnLeave(client, oldFaction)
    if IsValid(client) then
        client:SetWalkSpeed(self.defaultWalk)
        client:SetRunSpeed(self.defaultRun)
    end
end

FACTION_VORT = FACTION.index

