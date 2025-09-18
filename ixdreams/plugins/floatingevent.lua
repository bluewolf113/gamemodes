local PLUGIN = PLUGIN

PLUGIN.name = "Subtitled Event"
PLUGIN.author = "redone by not tiger"
PLUGIN.description = "Adds commands for floating event text."



ix.lang.AddTable("english", {
    cmdFloatingEvent = "A global event that everyone can see as fading subtitles for 12 seconds."
})

ix.lang.AddTable("english", {
    cmdFloatingEventTimed = "A global event that everyone can see as fading subtitles for a custom lifetime."
})

ix.lang.AddTable("english", {
    cmdFloatingEventLocal = "A local event that everyone can see as fading subtitles for 12 seconds."
})

--[[ ix.lang.AddTable("english", {
    cmdFloatingEventLocalCustom = "A local event that everyone can see as fading subtitles for a custom timespan."
}) --]]

ix.command.Add("FloatingEvent", {
    description = "@cmdFloatingEvent",
    arguments = {ix.type.text},
    adminOnly = true,
    OnRun = function(self, client, event)
        ix.chat.Send(client, "FloatingEvent", event)
    end
})

ix.chat.Register("FloatingEvent", {
    CanHear = 1000000,
    OnChatAdd = function(self, speaker, event)
        PLUGIN:AddSubtitle(event, 12)
    end,
    indicator = "chatPerforming"
})


ix.command.Add("FloatingEventTimed", {
    description = "@cmdFloatingEventTimed",
    arguments = {ix.type.number, ix.type.text},
    adminOnly = true,
    OnRun = function(self, client, lifetime, event)
        ix.chat.Send(client, "FloatingEventTimed", event, nil, nil, {length = lifetime})
    end
})

ix.chat.Register("FloatingEventTimed", {
    CanHear = 1000000,
    OnChatAdd = function(self, speaker, event, data) -- data is actually a boolean, which is actually ix.chat.Send anonymous value, which is meant to be nil ????
        PLUGIN:AddSubtitle(event, tonumber(ix.chat.currentArguments[1]))
    end,
    indicator = "chatPerforming"
})


/*
ix.command.Add("FloatingEventLocal", {
    description = "@cmdFloatingEventLocal",
    arguments = {ix.type.string, bit.bor(ix.type.number, ix.type.optional)},
    adminOnly = true,
    OnRun = function(self, client, event, radius)
        ix.chat.Send(client, "FloatingEventLocal", event, nil, nil, {range = radius})
    end
})

*/

ix.command.Add("FloatingEventTarget", {
    adminOnly = true,
    arguments = {ix.type.player, ix.type.text},
    OnRun = function(self, client, target, event)
        ix.chat.Send(client, "FloatingEventTarget", event, false, {client, target})
    end
})

ix.chat.Register("FloatingEventTarget", {
    OnChatAdd = function(self, speaker, event)
        PLUGIN:AddSubtitle(event, 12)
    end 
})

do
	local CLASS = {}
	CLASS.adminOnly = true
	CLASS.indicator = "chatPerforming"

	function CLASS:CanHear(speaker, listener, data)
		return (speaker:GetPos() - listener:GetPos()):LengthSqr() <= (data.range and data.range ^ 2 or 250000)
	end

	function CLASS:OnChatAdd(speaker, text)
		PLUGIN:AddSubtitle(text, 12)
	end

	ix.chat.Register("FloatingEventLocal", CLASS)
end

--[[ ix.chat.Register("FloatingEventLocal", {
     -- why functions storing anonymous from ix.chat.send i do not yet know
    CanHear = function(speaker, listener, data)
        print("hello?")
        return 1000000
	    -- return (speaker:GetPos() - listener:GetPos()):LengthSqr() <= (data.range and data.range ^ 2 or 250000)
	end,
    OnChatAdd = function(self, speaker, event, anonymous, data)
        PLUGIN:AddSubtitle("hello", 12)
    end,
    indicator = "chatPerforming"
}) --]]


--[[ ix.command.Add("FloatingEventLocalCustom", {
    description = "@cmdFloatingEventLocalCustom",
    arguments = {
        ix.type.string, 
        bit.bor(ix.type.number, ix.type.optional),
        bit.bor(ix.type.number, ix.type.optional)
    },
    adminOnly = true,
    OnRun = function(self, client, event, radius, optionalLifetime)
        ix.chat.Send(client, "FloatingEventLocalCustom", event, nil, nil, {range = radius}, {length = optionalLifetime})
    end
})

ix.chat.Register("FloatingEventLocalCustom", {
    CanHear = function(speaker, listener, data)
		return (speaker:GetPos() - listener:GetPos()):LengthSqr() <= (data.range and data.range ^ 2 or 250000)
	end,
    OnChatAdd = function(self, speaker, event)
        PLUGIN:AddSubtitle(event, (tonumber(ix.chat.currentArguments[3]) or 12))
    end,
    indicator = "chatPerforming"
}) --]]




if (CLIENT) then
    
    /*
    surface.CreateFont("ixChatSubtitleFontEvent", {
        font = "Bell MT",
        size = ScreenScale(8),
        extenxxded = true,
        weight = 600
    }) */

    PLUGIN.subtitles = {}
    PLUGIN.subtitleFont = "ixChatSubtitleFontEvent"
    -- PLUGIN.subtitleFont = "ixGenericFont"
    local scrW = ScrW()
    local scrH = ScrH()

    function PLUGIN:AddSubtitle(text, lifetime)
        local tbl = {""}

        local wrap = ix.util.WrapText(text, math.max(scrW * 0.5, 800), self.subtitleFont, tbl)

        self.subtitles[#self.subtitles + 1] = {
            start = RealTime(),
            finish = RealTime() + lifetime,
            fadeIn = 1,
            fadeOut = 1,
            text = wrap,
        }
    end

    function PLUGIN:HUDPaint()
        local t = RealTime()
        local x, y = scrW * 0.5, scrH * 0.8

        if (not self.subtitles) then
            self.subtitles = {}
        end

        if (#self.subtitles >= 5) then -- if num of active subtitles >= 5 then remove first element
            table.remove(self.subtitles, 1)
        end


        local messages = self.subtitles

        for k, v in pairs(messages) do
            local subtitleData = messages[k]
            local subtitle = v

            if t >= subtitleData.finish then
                table.remove(messages, k)
            else
                local a = 1.0

                if t < subtitleData.start + subtitleData.fadeIn then -- this generates the fading in effect/alpha
                    a = (t - subtitleData.start) / subtitleData.fadeIn
                elseif t > subtitleData.finish - subtitleData.fadeOut then -- this generates the fading out effect/alpha
                    a = (subtitleData.finish - t) / subtitleData.fadeOut
                end

                local c = 255 * a

                for k2, v2 in ipairs(subtitle.text) do
                    y = y + 20
                    subOutput = ix.util.DrawText(v2, x, y - 200, ColorAlpha(color_white, c), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, self.subtitleFont, false)
                end
            end
        end
    end

    /*
    function PLUGIN:PostDrawTranslucentRenderables(bDrawingDepth, bDrawingSkybox)
		if (bDrawingDepth or bDrawingSkybox) then
			return
		end

        -- does this work as intended??
		if (ix.chat.currentCommand == "FloatingEventlocal") then
			render.SetColorMaterial()
			render.DrawSphere(LocalPlayer():GetPos(), -(tonumber(ix.chat.currentArguments[2]) or 500), 30, 30, Color(255, 150, 0, 100))
		end
	end
    */
end