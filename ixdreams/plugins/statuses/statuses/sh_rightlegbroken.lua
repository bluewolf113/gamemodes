local PLUGIN = PLUGIN
local STATUS = {}

STATUS.name = "Right Leg Broken"
STATUS.uniqueID = "rightlegbroken"

-- Trigger on fall damage, 50% chance
STATUS.condition = function(ply, dmgInfo, hitgroup, dt)
    return bit.band(dt, DMG_FALL) ~= 0 and math.random(2) == 1
end

function STATUS:OnApply(client, scaleFactor)
    local character = client:GetCharacter()
    if not character then return end

    client:ChatPrint("Your right leg is broken!")
    -- Halve movement speeds
    client:SetWalkSpeed(client:GetWalkSpeed() * 0.5)
    client:SetRunSpeed(client:GetRunSpeed() * 0.5)
end

function STATUS:OnRemove(client)
    client:ChatPrint("Your right leg heals.")
    -- Reset to config defaults
    client:SetWalkSpeed(ix.config.Get("walkSpeed", 130))
    client:SetRunSpeed(ix.config.Get("runSpeed", 235))
end

PLUGIN:RegisterStatusEffect(STATUS)
