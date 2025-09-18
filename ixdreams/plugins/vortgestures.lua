local PLUGIN = PLUGIN

PLUGIN.name = "Vortigaunt Gestures"
PLUGIN.description = "Adds custom gesture support exclusively for Vortigaunts."
PLUGIN.author = "Nicholas Edit"
PLUGIN.schema = "Any"

-- Only runs for this faction
local VORT_FACTION = FACTION_VORT

-- =========================
-- VORTIGAUNT GESTURE SET
-- =========================
PLUGIN.vortGestures = {
    {gesture = "g_accent2hands_01",       command = "Idle",     id = 2000, randomized = true},
    {gesture = "vort_point",      command = "Point",    id = 2001, randomized = true},
    {gesture = "vort_zapattack1", command = "Zap",      id = 2002, randomized = false},
    {gesture = "vort_praise",     command = "Praise",   id = 2003, randomized = true},
    {gesture = "vort_bow",        command = "Bow",      id = 2004, randomized = false}
}

-- =========================
-- SETTINGS
-- =========================
PLUGIN.cooldowns = {}
PLUGIN.gestureCooldown = 5
PLUGIN.skipChance = 0.4

-- =========================
-- PLAYBACK HOOK
-- =========================
function PLUGIN:DoAnimationEvent(ply, event, data)
    if event ~= PLAYERANIMEVENT_CUSTOM_GESTURE then return end
    if ply:Team() ~= VORT_FACTION then return end

    for _, v in ipairs(self.vortGestures) do
        if data == v.id then
            local seq = ply:LookupSequence(v.gesture)
            if seq and seq >= 0 then
                ply:AddVCDSequenceToGestureSlot(GESTURE_SLOT_CUSTOM, seq, 1, true)
            end
            return ACT_INVALID
        end
    end
end

-- =========================
-- CHAT-TRIGGERED RANDOM GESTURES
-- =========================
if SERVER then
    local allowedChatTypes = { ic = true, w = true, y = true }

    function PLUGIN:PrePlayerMessageSend(ply, chatType, message)
        if ply:Team() ~= VORT_FACTION then return end
        if not allowedChatTypes[chatType] then return end

        local now = CurTime()
        local last = self.cooldowns[ply] or 0
        if now - last < self.gestureCooldown then return end
        if math.Rand(0, 1) < self.skipChance then return end

        local pool = {}
        for _, v in ipairs(self.vortGestures) do
            if v.randomized then pool[#pool + 1] = v end
        end

        if #pool > 0 then
            local pick = pool[math.random(#pool)]
            ply:DoAnimationEvent(PLAYERANIMEVENT_CUSTOM_GESTURE, pick.id)
            self.cooldowns[ply] = now
        end
    end
end

-- =========================
-- COMMAND REGISTRATION
-- =========================
if SERVER then
    for _, v in ipairs(PLUGIN.vortGestures) do
        -- Console command
        concommand.Add("ix_vortact_" .. v.command, function(ply)
            if not IsValid(ply) or ply:Team() ~= VORT_FACTION then
                ply:ChatPrint("You must be a Vortigaunt to use this gesture.")
                return
            end
            ply:DoAnimationEvent(PLAYERANIMEVENT_CUSTOM_GESTURE, v.id)
        end)

        -- Chat command
        ix.command.Add("VortGesture" .. v.command, {
            description = "Play the " .. v.command .. " gesture (Vortigaunts only).",
            OnCanRun = function(_, ply) return ply:Team() == VORT_FACTION end,
            OnRun = function(_, ply) ply:ConCommand("ix_vortact_" .. v.command) end
        })
    end
end
