local PLUGIN = PLUGIN
PLUGIN.name = "Fading Text"
PLUGIN.description = ""
PLUGIN.author = "niggascalper"

if (SERVER) then
    util.AddNetworkString("MiddleTextMessage")

    function SendMiddleText(m, i, o, e, p)
        local m = m
        local i = i
        local o = o
        local e = e
        local p = p or nil
        net.Start("MiddleTextMessage")
        net.WriteString(m)
        net.WriteInt(i, 32)
        net.WriteInt(o, 32)
        net.WriteInt(e, 32)

        if p then
            net.Send(p)
        else
            net.Broadcast()
        end
    end
else
    surface.CreateFont("ixMiddleText", {
        font = "EB Garamond Medium",
        size = ScreenScale(14),
        extended = true,
        weight = 400
    })

    local messages = message or {}
    local FONT_NAME = "ixMiddleText"

    function SendMiddleText(m, i, o, e)
        local data = {}
        data.message = m
        data.fadeIn = i
        data.fadeOut = o
        data.start_time = RealTime()
        data.end_time = RealTime() + e
        table.insert(messages, data)
    end

    net.Receive("MiddleTextMessage", function(len)
        local m = net.ReadString()
        local i = net.ReadInt(32)
        local o = net.ReadInt(32)
        local e = net.ReadInt(32)
        SendMiddleText(m, i, o, e)
    end)

    function PLUGIN:HUDPaint()
        local t = RealTime()
        local scrW = ScrW()
        local scrH = ScrH()
        local x, y = scrW / 2, scrH / 3

        for k, v in ipairs(messages) do
            local data = messages[k]

            if t >= data.end_time then
                table.remove(messages, k)
            else
                local a = 1.0

                if t < data.start_time + data.fadeIn then
                    a = (t - data.start_time) / data.fadeIn
                elseif t > data.end_time - data.fadeOut then
                    a = (data.end_time - t) / data.fadeOut
                end

                local textInfo = {}
                local msg = data.message

                if msg then
                    textLines = ix.util.WrapText(msg, math.max(scrW * 0.7, 450), FONT_NAME)
                end

                for i = 1, #textLines do
                    textInfo[#textInfo + 1] = {textLines[i]}
                end

                local drawText = ix.util.DrawTextAligned

                for i = 1, #textInfo do
                    local info = textInfo[i]
                    local c = 255 * a
                    y = ix.util.DrawTextAligned(info[1], x, y, Color(200, 200, 200), c, FONT_NAME)
                end
            end
        end
    end
end

ix.command.Add("MiddleText", {
    adminOnly = true,
    arguments = {ix.type.text},
    OnRun = function(self, client, message)
        if message and message ~= "" then
            SendMiddleText(message, 3, 3, 10)

            
        end
    end
})

ix.command.Add("MiddleTextTarget", {
    adminOnly = true,
    arguments = {ix.type.player, ix.type.number, ix.type.text},
    argumentNames = {"target", "lifetime [2 - 32]", "message"},
    OnRun = function(self, client, target, lifetime, message)
        if message and message ~= "" then
            local clmp = math.Clamp(lifetime, 2, 16)
            SendMiddleText(message, 3, 3, clmp, target)

            
        end
    end
})

ix.command.Add("MiddleTextRadius", {
    adminOnly = true,
    arguments = {ix.type.number, ix.type.text},
    argumentNames = {"radius [32 - 8192]", "message"},
    OnRun = function(self, client, radius, message)
        if message and message ~= "" then
            local clmp = math.Clamp(radius, 32, 8192)

            for k, v in ipairs(ents.FindInSphere(client:GetPos(), clmp)) do
                if IsValid(v) and v:IsPlayer() and v:GetCharacter() then
                    SendMiddleText(message, 3, 3, 8, v)

                   
                end
            end
        end
    end
})