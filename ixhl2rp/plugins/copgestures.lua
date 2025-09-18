local PLUGIN = PLUGIN

PLUGIN.name = "Metrocop Gestures"
PLUGIN.description = "Adds gestures for Metrocop models, allowing proper RP animations."
PLUGIN.author = "Riggs (Modified for Metrocop by Copilot)"
PLUGIN.schema = "Any"

PLUGIN.gestures = { -- Metrocop animations
    {gesture = "buttonfront", command = "button", id = 1500},
}

function PLUGIN:DoAnimationEvent(ply, event, data)
    if ( event == PLAYERANIMEVENT_CUSTOM_GESTURE ) then
        for _, v in ipairs(self.gestures) do
            if ( data == v.id ) then
                ply:AddVCDSequenceToGestureSlot(GESTURE_SLOT_CUSTOM, ply:LookupSequence(v.gesture), 0, true)

                return ACT_INVALID
            end
        end
    end
end

for _, v in ipairs(PLUGIN.gestures) do
    local commandname = string.Replace(v.gesture, "mc_", "")

    concommand.Add("ix_act_"..v.command, function(ply, cmd, args)
        ply:DoAnimationEvent(v.id)
    end)

    ix.command.Add("MetrocopGesture"..v.command, {
        description = "Perform the "..commandname.." gesture.",
        OnRun = function(_, ply)
            if ( SERVER ) then
                ply:ConCommand("ix_act_"..v.command)
            end
        end
    })
end
