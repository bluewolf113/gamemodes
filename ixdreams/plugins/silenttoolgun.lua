
local PLUGIN = PLUGIN

PLUGIN.name = "Silent Toolgun"
PLUGIN.author = "P!"
PLUGIN.description = "Silences the toolgun sounds."

if SERVER then
    -- Hook to override the toolgun sound
    hook.Add("EntityEmitSound", "SilentToolgunSound", function(data)
        if IsValid(data.Entity) and data.Entity:GetClass() == "gmod_tool" then
            -- Prevent the sound from playing
            return false
        end
    end)
end
