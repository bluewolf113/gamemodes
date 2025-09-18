local PLUGIN = PLUGIN

PLUGIN.name = "Player Gestures"
PLUGIN.description = "Adds gestures that can be used for certain supported animations. Major thanks to Wicked Rabbit for showing me how it works!"
PLUGIN.author = "Riggs"
PLUGIN.schema = "Any"
PLUGIN.license = [[
Copyright 2024 Riggs

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

PLUGIN.maleGestures = {
    {gesture = "g_salute", command = "Salute", id = 1444, randomized = false},
    {gesture = "g_antman_dontmove", command = "DontMove", id = 1445, randomized = false},
    {gesture = "g_antman_stayback", command = "StayBack", id = 1446, randomized = false},
    {gesture = "g_armsout", command = "ArmSout", id = 1447, randomized = true},
    {gesture = "g_armsout_high", command = "ArmSoutHigh", id = 1448, randomized = false},
    {gesture = "g_chestup", command = "ChestUp", id = 1449, randomized = false},
    {gesture = "g_clap", command = "Clap", id = 1450, randomized = false},
    {gesture = "g_fist_L", command = "FistLeft", id = 1451, randomized = true},
    {gesture = "g_fist_r", command = "FistRight", id = 1452, randomized = true},
    {gesture = "g_fist_swing_across", command = "FistSwing", id = 1453, randomized = true},
    {gesture = "g_fistshake", command = "FistShake", id = 1454, randomized = false},
    {gesture = "g_frustrated_point_l", command = "PointFrustrated", id = 1455, randomized = false},
    {gesture = "G_noway_big", command = "No", id = 1456, randomized = false},
    {gesture = "G_noway_small", command = "NoSmall", id = 1457, randomized = true},
    {gesture = "g_plead_01", command = "Plead", id = 1458, randomized = false},
    {gesture = "g_point", command = "Point", id = 1459, randomized = false},
    {gesture = "g_point_swing", command = "PointSwing", id = 1460, randomized = true},
    {gesture = "g_pointleft_l", command = "PointLeft", id = 1461, randomized = false},
    {gesture = "g_pointright_l", command = "PointRight", id = 1462, randomized = false},
    {gesture = "g_present", command = "Present", id = 1463, randomized = true},
    {gesture = "G_shrug", command = "Shrug", id = 1464, randomized = true},
    {gesture = "g_thumbsup", command = "ThumbsUp", id = 1465, randomized = false},
    {gesture = "g_wave", command = "Wave", id = 1466, randomized = false},
    {gesture = "G_what", command = "What", id = 1467, randomized = false},
    {gesture = "hg_headshake", command = "HeadShake", id = 1468, randomized = false},
    {gesture = "hg_nod_no", command = "HeadNo", id = 1469, randomized = false},
    {gesture = "hg_nod_yes", command = "HeadYes", id = 1470, randomized = false},
    {gesture = "hg_nod_left", command = "HeadLeft", id = 1471, randomized = false},
    {gesture = "hg_nod_right", command = "HeadRight", id = 1472, randomized = false},
    {gesture = "open_door_away", command = "door", id = 1473, randomized = false},
    {gesture = "open_door_away", command = "door", id = 1474, randomized = false},
}

-- Female-specific gestures
PLUGIN.femaleGestures = {
    {gesture = "g_arrest_clench", command = "Salute", id = 1444},
    {gesture = "gf_dontmove", command = "DontMove", id = 1445},
}

-- Cooldown duration in seconds
PLUGIN.gestureCooldown = 5
-- Probability to skip playing a gesture (0-1, where 0.3 means a 30% chance to skip)
PLUGIN.skipGestureProbability = .4

-- Cooldown tracker
PLUGIN.cooldowns = {}

function PLUGIN:DoAnimationEvent(ply, event, data)
    if event == PLAYERANIMEVENT_CUSTOM_GESTURE then
        local gestures = ply:IsFemale() and self.femaleGestures or self.maleGestures

        for _, v in ipairs(gestures) do
            if data == v.id then
                ply:AddVCDSequenceToGestureSlot(GESTURE_SLOT_CUSTOM, ply:LookupSequence(v.gesture), 0, true)
                return ACT_INVALID
            end
        end
    end
end

-- Enable chat-triggered gestures with cooldown and skip probability
if SERVER then
    local allowedChatTypes = {["ic"] = true, ["w"] = true, ["y"] = true}

    function PLUGIN:PrePlayerMessageSend(ply, chatType, message)
        if allowedChatTypes[chatType] then
            -- Cooldown logic
            local lastGestureTime = self.cooldowns[ply] or 0
            local currentTime = CurTime()

            if currentTime - lastGestureTime < PLUGIN.gestureCooldown then
                return -- Cooldown active, skip gesture
            end

            -- Skip gesture based on probability
            if math.random() < PLUGIN.skipGestureProbability then
                return -- Skip gesture entirely
            end

            -- Select gestures based on gender
            local gestures = ply:IsFemale() and PLUGIN.femaleGestures or PLUGIN.maleGestures

            -- Filter gestures to only include randomized ones
            local randomizedGestures = {}
            for _, v in ipairs(gestures) do
                if v.randomized then
                    table.insert(randomizedGestures, v)
                end
            end

            -- Pick a random gesture from the filtered list
            local randomGesture = randomizedGestures[math.random(#randomizedGestures)]
            if randomGesture then
                ply:DoAnimationEvent(randomGesture.id)
                self.cooldowns[ply] = currentTime -- Update cooldown
            end
        end
    end
end

-- Register gestures dynamically
local function RegisterGestures(gestures, isFemale)
    for _, v in ipairs(gestures) do
        -- Console command for gestures
        concommand.Add("ix_act_" .. v.command, function(ply)
            if (isFemale and not ply:IsFemale()) or (not isFemale and ply:IsFemale()) then
                ply:ChatPrint("You cannot use this gesture.")
                return
            end

            -- Play gesture immediately (no cooldown for manual commands)
            ply:DoAnimationEvent(v.id)
        end)

        -- Chat command for gestures
        ix.command.Add("Gesture" .. v.command, {
            description = "Play the " .. v.command .. " gesture.",
            OnCanRun = function(_, ply)
                return (isFemale and ply:IsFemale()) or (not isFemale and not ply:IsFemale())
            end,
            OnRun = function(_, ply)
                ply:ConCommand("ix_act_" .. v.command)
            end
        })
    end
end

-- Register male and female gestures
RegisterGestures(PLUGIN.maleGestures, false)
RegisterGestures(PLUGIN.femaleGestures, true)