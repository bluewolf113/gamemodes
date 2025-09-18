local ix = ix
local PLUGIN = PLUGIN
PLUGIN.name = "Scroll Text"
PLUGIN.description = "Provides an interface for drawing and sending 'scrolling text.'"
PLUGIN.author = "Chessnut"
PLUGIN.scroll = PLUGIN.scroll or {}
PLUGIN.scroll.buffer = PLUGIN.scroll.buffer or {}
local CHAR_DELAY = 0.08 -- 0.1

if CLIENT then
    surface.CreateFont("ixScrollFont", {
        font = "Times New Roman",
        size = ScreenScale(14),
        extended = true,
        weight = 400
    })

    function PLUGIN:AddScrollText(text, callback)
        local info = {
            text = "",
            callback = callback,
            nextChar = 0,
            char = "",
        }

        local index = table.insert(self.scroll.buffer, info)
        local i = 1

        timer.Create("ScrollText." .. tostring(info), CHAR_DELAY, #text, function()
            if info then
                info.text = string.sub(text, 1, i)
                i = i + 1

                if text ~= "\n" then
                    LocalPlayer():EmitSound("ambient/machines/keyboard" .. math.random(1, 6) .. "_clicks.wav", 40, math.random(120, 140))
                else
                    LocalPlayer():EmitSound("ambient/machines/keyboard7_clicks_enter.wav", 40)
                end

                if i >= #text then
                    info.char = ""
                    info.start = RealTime() + 3
                    info.finish = RealTime() + 5
                end
            end
        end)
    end

    function PLUGIN:HUDPaint()
        local curTime = RealTime()

        for k, v in ipairs(self.scroll.buffer) do
            -- local data = self.scroll.buffer[k]
            local alpha = 255

            if v.start and v.finish then
                alpha = 255 - math.Clamp(math.TimeFraction(v.start, v.finish, curTime) * 255, 0, 255)
            elseif v.nextChar < curTime then
                v.nextChar = curTime + 0.05
            end

            local text = v.text
            local font = "ixScrollFont"
            local lines = ix.util.WrapText(text, ScrW() * 0.8, font)
            local drawText = ix.util.DrawTextAligned
            local x = ScrW() / 2
            local y = ScrH() / 3

            for i = 1, #lines do
                local line = lines[i]
                y = y + (k * 40) -- 48
                ix.util.DrawTextAligned(line, x, y, Color(255, 255, 255, alpha), nil, font)
            end

            if alpha == 0 then
                if v.callback then
                    v.callback()
                end

                table.remove(self.scroll.buffer, k)
            end
        end
    end

    net.Receive("ixScrollData", function(len)
        PLUGIN:AddScrollText(net.ReadString())
    end)
else
    util.AddNetworkString("ixScrollData")

    function PLUGIN:Send(text, receiver, callback)
        net.Start("ixScrollData")
        net.WriteString(text)
        net.Send(receiver)

        timer.Simple(CHAR_DELAY * #text + 4, function()
            if callback then
                callback()
            end
        end)
    end

    function AddScrollText(text, receiver, callback)
        return PLUGIN:Send(text, receiver, callback)
    end
end

ix.command.Add("ScrollText", {
    adminOnly = true,
    arguments = {ix.type.text},
    OnRun = function(self, client, text)
        if text == "" then return end

        for k, v in ipairs(player.GetAll()) do
            PLUGIN:Send(text, v)

            ix.chat.Send(client, "pit", text, false, {v})
        end
    end
})

ix.command.Add("ScrollTextTarget", {
    adminOnly = true,
    arguments = {ix.type.player, ix.type.text},
    OnRun = function(self, client, target, text)
        if text == "" then return end
        PLUGIN:Send(text, target)

        ix.chat.Send(client, "pit", text, false, {client, target})
    end
})

ix.command.Add("ScrollTextRadius", {
    adminOnly = true,
    arguments = {ix.type.number, ix.type.text},
    argumentNames = {"radius [32 - 8192]", "message"},
    OnRun = function(self, client, radius, text)
        if text == "" then return end
        local clmp = math.Clamp(radius, 32, 8192)

        for k, v in ipairs(ents.FindInSphere(client:GetPos(), clmp)) do
            if IsValid(v) and v:IsPlayer() and v:GetCharacter() then
                PLUGIN:Send(text, v)

                ix.chat.Send(client, "pit", text, false, {v})
            end
        end
    end
})