--[[
	© 2020 TERRANOVA do not share, re-distribute or modify
	without permission of its author.
--]]

local PLUGIN = PLUGIN;

function PLUGIN:GetPlayerPainSound(client)
	if (client:GetCharacter():IsVortigaunt()) then
		local PainVort = {
			"vo/npc/vortigaunt/vortigese11.wav",
			"vo/npc/vortigaunt/vortigese07.wav",
			"vo/npc/vortigaunt/vortigese03.wav",
		}
		local vort_pain = table.Random(PainVort)
		return vort_pain
	end
end

function PLUGIN:GetPlayerDeathSound(client)
	if (client:GetCharacter():IsVortigaunt()) then
		return false
	end
end

-- Called when the client is checking if it has access to see the character panel
function PLUGIN:CharPanelCanUse(client)
	local faction = client:GetCharacter():GetFaction()

	if(faction == FACTION_VORT or faction == FACTION_BIOTIC) then
		return false
	end
end;

ix.chat.Register("VortComms", {
    format = "%s communes through the Vortessence, \"%s\"",
    GetColor = function(self, speaker, text)
        -- Distinct telepathy color
        return Color(100, 255, 180)
    end,
    CanHear = function(self, speaker, listener)
        -- Only other free Vorts can hear
        if not listener:GetCharacter() then return false end
        return listener:Team() == FACTION_VORT and listener:GetCharacter():GetClass() == CLASS_FREEVORT
    end,
    CanSay = function(self, speaker, text)
        local char = speaker:GetCharacter()
        if not char then return false end

        -- Not a Vort
        if speaker:Team() ~= FACTION_VORT then
            speaker:Notify("You are not connected to the Vortessence.")
            return false
        end

        local class = char:GetClass()

        -- Vort but Biotic (explicitly severed)
        if class == CLASS_BIOTIC then
            speaker:Notify("Your connection has been severed. You are torn from your kin.")
            return false
        end

        -- Check vortessence level
        local vortessence = char:GetNeed("vortessence") or 0
        if vortessence < 10 then
            speaker:Notify("Your Vortal connection is exhausted.")
            return false
        end

        -- Subtract 10 vortessence
        char:SetNeed("vortessence", math.max(vortessence - 50, 0))

        return true
    end,
    OnChatAdd = function(self, speaker, text, anonymous, info)
        local color = self:GetColor(speaker, text, info)
        local name = anonymous and
            L"someone" or hook.Run("GetCharacterName", speaker, chatType) or
            (IsValid(speaker) and speaker:Name() or "Console")

        chat.AddText(color, string.format(self.format, name, text))
    end,
    prefix = {"/vt", "/vortcomms"},
    description = "Communicate telepathically with other free Vortigaunts.",
    indicator = "chatTalking",
    deadCanChat = false
})


