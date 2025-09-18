FACTION.name = "Stalker"
FACTION.isDefault = false
FACTION.isHidden = false
FACTION.isGloballyRecognized = false
FACTION.color = Color(240, 230, 140)
FACTION.models = {"models/stalker.mdl"}
FACTION.walkSounds = {[0] = "NPC_Stalker.FootstepLeft", [1] = "NPC_Stalker.FootstepRight"}

-- Store default speeds so we can restore them later
FACTION.defaultWalk = ix.config.Get("walkSpeed", 130)
FACTION.defaultRun  = ix.config.Get("runSpeed", 235)

function FACTION:OnSpawn(client, character)
    client:SetWalkSpeed(self.defaultWalk * 0.55)
	client:SetRunSpeed(self.defaultRun * 0.75) -- 75% slower
    character:SetData("chatRestricted", true)

end

function FACTION:OnTransferred(client)
    local character = client:GetCharacter()
    character:SetModel(self.models[1])

    -- Apply slower walk speed when transferred into this faction
    client:SetWalkSpeed(self.defaultWalk * 0.85)
	client:SetRunSpeed(self.defaultRun * 0.75)
    character:SetData("chatRestricted", true)

end

-- When they leave this faction, restore normal speeds
function FACTION:OnLeave(client, oldFaction)
    if IsValid(client) then
        client:SetWalkSpeed(self.defaultWalk)
        client:SetRunSpeed(self.defaultRun)
    end
end

function FACTION:PlayerUnloadedCharacter(client, character)
    character:SetData("chatRestricted", nil)
end


FACTION_STALKER = FACTION.index