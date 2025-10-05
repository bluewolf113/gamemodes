local PLUGIN = PLUGIN
local STATUS = {}

STATUS.name = "Fever"
STATUS.uniqueID = "fever"

-- No condition: must be applied manually
STATUS.condition = function(ply, dmgInfo, hitgroup, dt)
    return false
end

local PLUGIN = PLUGIN
local STATUS = {}

STATUS.name = "Fever"
STATUS.uniqueID = "fever"

-- No condition: must be applied manually
STATUS.condition = function(ply, dmgInfo, hitgroup, dt)
    return false
end

function STATUS:OnApply(client, scaleFactor)
    client:ChatPrint("You feel feverish...")

    -- Looping fever sound
    --client:EmitSound("ambient/fire/fire_small_loop1.wav", 60, 50, 0.4)

    if SERVER then
        net.Start("ix_StartFeverEffects")
        net.Send(client)
    end
end

function STATUS:OnRemove(client)
    client:ChatPrint("Your fever breaks.")

    -- Stop fever sound
    client:StopSound("ambient/fire/fire_small_loop1.wav")

    if SERVER then
        net.Start("ix_EndFeverEffects")
        net.Send(client)
    end
end

-- CLIENT‑SIDE EFFECTS
if CLIENT then
    net.Receive("ix_StartFeverEffects", function()
        local client = LocalPlayer()
        if not IsValid(client) then return end

        -- High contrast overlay
        hook.Add("RenderScreenspaceEffects", "ixFeverContrast", function()
            local tab = {}
            tab["$pp_colour_colour"] = 0.8
            tab["$pp_colour_brightness"] = .1
            DrawColorModify(tab)
        end)
    end)

    net.Receive("ix_EndFeverEffects", function()
        hook.Remove("RenderScreenspaceEffects", "ixFeverContrast")
    end)
end

-- SERVER networking
if SERVER then
    util.AddNetworkString("ix_StartFeverEffects")
    util.AddNetworkString("ix_EndFeverEffects")
end

PLUGIN:RegisterStatusEffect(STATUS)
