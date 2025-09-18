PLUGIN.name = "Colored Chat";
PLUGIN.description = "Colored Chat";
PLUGIN.author = "spr1te (fixed by jb xD)";

local character = ix.meta.character

function character:GetFactionColor()
    return ix.faction.Get(self:GetFaction()).color or Color(66,66,100)
end

if CLIENT then
	surface.CreateFont("ixComputerFont", {
		font = "Consolas",
		size = math.max(ScreenScale(9), 17) * ix.option.Get("chatFontScale", 1),
		weight = 1000,
		antialias = true
	})
end

local pcSounds = {
    "vocals/pc_talking1.ogg",
    "vocals/pc_talking1.ogg",
    "vocals/pc_talking1.ogg",
    "vocals/pc_talking1.ogg",
    "vocals/pc_talking1.ogg",
    "vocals/pc_talking2.ogg",
    "vocals/pc_talking2.ogg",
    "vocals/pc_talking2.ogg",
    "vocals/pc_talking3.ogg",
    "vocals/pc_talking4.ogg",
    "vocals/pc_talking4.ogg"
}

hook.Add("InitializedConfig", "ixChatTypes", function()

    /*
    ix.chat.Register("CSpeak", {
        format = "The Computer outputs: \"%s\"",
        indicator = "chatTalking",
        font = "ixComputerFont",
        --superAdminOnly = true,
        OnChatAdd = function(self, speaker, text)
            if (!speaker:IsAdmin()) then
                return
            end

            local chatColor = ix.config.Get("chatColor")

            speaker:EmitSound(pcSounds[math.random(1, #pcSounds)], 100, 100, 100)

            chat.AddText(ix.config.Get("chatListenColor"), "The Computer", ix.config.Get("chatListenColor"), " outputs: ", string.format("'%s'", text))
        end,
        CanHear = ix.config.Get("chatRange", 280),
        prefix = {"/CSpeak"},
        description = "Speak as the computer"
    })

    ix.chat.Register("CAnnounce", {
        format = "The Computer announces: \"%s\"",
        indicator = "chatTalking",
        font = "ixComputerFont",
        --superAdminOnly = true,
        OnChatAdd = function(self, speaker, text)
            if (!speaker:IsAdmin()) then
                return
            end

            local chatColor = ix.config.Get("chatColor")

            for _, ply in ipairs( player.GetAll() ) do
                ply:EmitSound(pcSounds[math.random(1, #pcSounds)])
            end

            --speaker:EmitSound(pcSounds[math.random(1, #pcSounds)], 100, 100, 100)

            chat.AddText(Color(224,134,38), "The Computer", Color(224,134,38), " announces: ", string.format("'%s'", text))
        end,
        CanHear = ix.config.Get("chatRange", 280) * 99999,
        prefix = {"/CAnnounce"},
        description = "Announce as the computer"
    })
    */

    ix.chat.Register("ic", {
        format = "%s says \"%s\"",
        indicator = "chatTalking",
        OnChatAdd = function(self, speaker, text, anonymous)
            if (!IsValid(speaker)) then
                return
            end

            local name = anonymous and
            L"someone" or hook.Run("GetCharacterName", speaker, "me") or
            (IsValid(speaker) and speaker:Name() or "Console")

            local chatColor = ix.config.Get("chatColor")

            if (LocalPlayer():GetEyeTrace().Entity == speaker) then
                chatColor = ix.config.Get("chatListenColor")
            end

            chat.AddText(speaker:GetCharacter():GetFactionColor(), name, chatColor, " says ", string.format("\"%s\"", text))

        end,
        CanHear = ix.config.Get("chatRange", 280)
    })

    -- Actions and such.
    ix.chat.Register("me", {
        CanHear = ix.config.Get("chatRange", 280) * 1.5,
        OnChatAdd = function(self, speaker, text, anonymous)
            if (!IsValid(speaker)) then
                return
            end

            local name = anonymous and
            L"someone" or hook.Run("GetCharacterName", speaker, "me") or
            (IsValid(speaker) and speaker:Name() or "Console")

            local chatColor = ix.config.Get("chatColor")

            chat.AddText(chatColor, "*** ", speaker:GetCharacter():GetFactionColor(), name, chatColor, " ", text)
        end,
        prefix = {"/Me", "/Action"},
        description = "@cmdMe",
        indicator = "chatPerforming",
        deadCanChat = true
    })

    ix.chat.Register("mel", {
        OnChatAdd = function(self, speaker, text, anonymous)
            if (!IsValid(speaker)) then
                return
            end

            local name = anonymous and
            L"someone" or hook.Run("GetCharacterName", speaker, "me") or
            (IsValid(speaker) and speaker:Name() or "Console")

            local chatColor = ix.config.Get("chatColor")

            chat.AddText(chatColor, "***** ", speaker:GetCharacter():GetFactionColor(), name, chatColor, " ", text)
        end,
		CanHear = ix.config.Get("chatRange", 280) * 4,
		prefix = {"/MeL", "/ActionLong"},
		description = "@cmdMe",
		indicator = "chatPerforming",
		deadCanChat = true
	})

	ix.chat.Register("mec", {
        OnChatAdd = function(self, speaker, text, anonymous)
            if (!IsValid(speaker)) then
                return
            end

            local name = anonymous and
            L"someone" or hook.Run("GetCharacterName", speaker, "me") or
            (IsValid(speaker) and speaker:Name() or "Console")

            local chatColor = ix.config.Get("chatColor")

            chat.AddText(chatColor, "** ", speaker:GetCharacter():GetFactionColor(), name, chatColor, " ", text)
        end,
		CanHear = ix.config.Get("chatRange", 280) * 0.25,
		prefix = {"/MeC", "/ActionClose"},
		description = "@cmdMe",
		indicator = "chatPerforming",
		deadCanChat = true
	})

	ix.chat.Register("med", {
        OnChatAdd = function(self, speaker, text, anonymous)
            if (!IsValid(speaker)) then
                return
            end

            local name = anonymous and
            L"someone" or hook.Run("GetCharacterName", speaker, "me") or
            (IsValid(speaker) and speaker:Name() or "Console")

            local chatColor = ix.config.Get("chatColor")

            chat.AddText(chatColor, "* ", speaker:GetCharacter():GetFactionColor(), name, chatColor, " ", text)
        end,
		CanHear = function(_, speaker, listener)
			local entFacing = speaker:GetEyeTraceNoCursor().Entity

			if (IsValid(entFacing) and entFacing:IsPlayer()) then
				return ((entFacing == listener) && (listener == speaker))
			else
				return false
			end
		end,
		prefix = {"/MeD", "/ActionDirect"},
		description = "@cmdMe",
		indicator = "chatPerforming",
		deadCanChat = true
	})

    -- Actions and such.
    ix.chat.Register("it", {
        OnChatAdd = function(self, speaker, text, anonymous)
            chat.AddText(ix.config.Get("chatColor"), "*** "..text)
        end,
        CanHear = ix.config.Get("chatRange", 280) * 1.5,
        prefix = {"/It"},
        description = "@cmdIt",
        indicator = "chatPerforming",
        deadCanChat = true
    })

    ix.chat.Register("itl", {
        OnChatAdd = function(self, speaker, text, anonymous)
            chat.AddText(ix.config.Get("chatColor"), "***** "..text)
        end,
		CanHear = ix.config.Get("chatRange", 280) * 4,
		prefix = {"/ItL"},
		description = "@cmdIt",
		indicator = "chatPerforming",
		deadCanChat = true
	})

	ix.chat.Register("itc", {
        OnChatAdd = function(self, speaker, text, anonymous)
            chat.AddText(ix.config.Get("chatColor"), "** "..text)
        end,
		CanHear = ix.config.Get("chatRange", 280) * 0.25,
		prefix = {"/ItC"},
		description = "@cmdIt",
		indicator = "chatPerforming",
		deadCanChat = true
	})

	ix.chat.Register("itd", {
        OnChatAdd = function(self, speaker, text, anonymous)
            chat.AddText(ix.config.Get("chatColor"), "* "..text)
        end,
		CanHear = function(_, speaker, listener)
			local entFacing = speaker:GetEyeTraceNoCursor().Entity

			if (IsValid(entFacing) and entFacing:IsPlayer()) then
				return (entFacing == listener)
			else
				return false
			end
		end,
		prefix = {"/ItD"},
		description = "@cmdIt",
		indicator = "chatPerforming",
		deadCanChat = true
	})

    -- Whisper chat.
    ix.chat.Register("w", {
        OnChatAdd = function(self, speaker, text, anonymous)
            if (!IsValid(speaker)) then
                return
            end
            local name = anonymous and
            L"someone" or hook.Run("GetCharacterName", speaker, "me") or
            (IsValid(speaker) and speaker:Name() or "Console")

            local chatColor = ix.config.Get("chatColor")
            chatColor = Color(chatColor.r - 35, chatColor.g - 35, chatColor.b - 35)

            chat.AddText(speaker:GetCharacter():GetFactionColor(), name, chatColor, " whispers ", string.format("\"%s\"", text))
        end,
        CanHear = ix.config.Get("chatRange", 280) * 0.25,
        prefix = {"/W", "/Whisper"},
        description = "@cmdW",
        indicator = "chatWhispering"
    })

    -- Yelling out loud.
    ix.chat.Register("y", {
        OnChatAdd = function(self, speaker, text, anonymous)
            if (!IsValid(speaker)) then
                return
            end
            local name = anonymous and
            L"someone" or hook.Run("GetCharacterName", speaker, "me") or
            (IsValid(speaker) and speaker:Name() or "Console")

            local chatColor = ix.config.Get("chatColor")
            chatColor = Color(chatColor.r + 35, chatColor.g + 35, chatColor.b + 35)

            chat.AddText(speaker:GetCharacter():GetFactionColor(), name, chatColor, " yells ", string.format("\"%s\"", text))

        end,
        CanHear = ix.config.Get("chatRange", 280) * 2,
        prefix = {"/Y", "/Yell"},
        description = "@cmdY",
        indicator = "chatYelling"
    })

    -- Out of character.
    ix.chat.Register("ooc", {
        CanSay = function(self, speaker, text)
            if (!ix.config.Get("allowGlobalOOC")) then
                speaker:NotifyLocalized("Global OOC is disabled on this server.")
                return false
            else
                local delay = ix.config.Get("oocDelay", 10)

                -- Only need to check the time if they have spoken in OOC chat before.
                if (delay > 0 and speaker.ixLastOOC) then
                    local lastOOC = CurTime() - speaker.ixLastOOC

                    -- Use this method of checking time in case the oocDelay config changes.
                    if (lastOOC <= delay and !CAMI.PlayerHasAccess(speaker, "Helix - Bypass OOC Timer", nil)) then
                        speaker:NotifyLocalized("oocDelay", delay - math.ceil(lastOOC))

                        return false
                    end
                end

                -- Save the last time they spoke in OOC.
                speaker.ixLastOOC = CurTime()
            end
        end,
        OnChatAdd = function(self, speaker, text)
            if (!IsValid(speaker)) then
                return
            end

            local icon = "icon16/user.png"

            icon = Material(hook.Run("GetPlayerIcon", speaker) or icon)

            chat.AddText(icon, Color(255, 50, 50), "[OOC] ", speaker:GetCharacter():GetFactionColor(), speaker:Name(), color_white, ": "..text)
        end,
        prefix = {"//", "/OOC"},
        description = "@cmdOOC",
        noSpaceAfter = true
    })

    -- Local out of character.
    ix.chat.Register("looc", {
        CanSay = function(self, speaker, text)
            local delay = ix.config.Get("loocDelay", 0)

            -- Only need to check the time if they have spoken in OOC chat before.
            if (delay > 0 and speaker.ixLastLOOC) then
                local lastLOOC = CurTime() - speaker.ixLastLOOC

                -- Use this method of checking time in case the oocDelay config changes.
                if (lastLOOC <= delay and !CAMI.PlayerHasAccess(speaker, "Helix - Bypass OOC Timer", nil)) then
                    speaker:NotifyLocalized("loocDelay", delay - math.ceil(lastLOOC))

                    return false
                end
            end

            -- Save the last time they spoke in OOC.
            speaker.ixLastLOOC = CurTime()
        end,
        OnChatAdd = function(self, speaker, text)
            chat.AddText(Color(255, 50, 50), "[LOOC] ", ix.config.Get("chatColor"), speaker:Name()..": "..text)
        end,
        CanHear = ix.config.Get("chatRange", 280),
        prefix = {".//", "[[", "/LOOC"},
        description = "@cmdLOOC",
        noSpaceAfter = true
    })



    ix.command.Add("Roll", {
        description = "@cmdRoll",
        arguments = bit.bor(ix.type.number, ix.type.optional),
        OnRun = function(self, client, maximum)
            maximum = math.Clamp(maximum or 20, 0, 1000000)
    
            local value = math.random(0, maximum)
    
            ix.chat.Send(client, "roll", tostring(value), nil, nil, {
                max = maximum
            })
    
            ix.log.Add(client, "roll", value, maximum)
        end
    })

    -- Roll information in chat.
    ix.chat.Register("roll", {
        format = "** %s has rolled %s out of %s.",
        color = Color(155, 111, 176),
        CanHear = ix.config.Get("chatRange", 280) * 1.5,
        deadCanChat = true,
        OnChatAdd = function(self, speaker, text, bAnonymous, data)
            chat.AddText(self.color, string.format(self.format,
                speaker:GetName(), text, data.max or 20
            ))
        end
    })
    

    -- run a hook after we add the basic chat classes so schemas/plugins can access their info as soon as possible if needed
    hook.Run("InitializedChatClasses")
end)