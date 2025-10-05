local PLUGIN = PLUGIN
local STATUS = {}

STATUS.name = "Left Arm Broken"
STATUS.uniqueID = "leftarmbroken"

-- Trigger on fall damage, 50% chance
--STATUS.condition = function(ply, dmgInfo, hitgroup, dt)
--    return bit.band(dt, DMG_FALL) ~= 0 and math.random(2) == 1
--end

function STATUS:OnApply(client, scaleFactor)
    client:ChatPrint("Your left arm is broken!")
    -- Halve movement speeds
    client:SetWalkSpeed(client:GetWalkSpeed() * 0.5)
    client:SetRunSpeed(client:GetRunSpeed() * 0.5)
end

function STATUS:OnRemove(client)
    client:ChatPrint("Your left leg heals.")
    -- Reset to config defaults
    client:SetWalkSpeed(ix.config.Get("walkSpeed", 130))
    client:SetRunSpeed(ix.config.Get("runSpeed", 235))
end

PLUGIN:RegisterStatusEffect(STATUS)
