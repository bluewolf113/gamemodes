PLUGIN.name = "Stat Based Rolling"
PLUGIN.description = "Per Dee's Request."
PLUGIN.author = "Blue and Copilot"

ix.chat.Register("rollstat", {
    prefix = {"/rollstat"},
    description = "Rolls a die with an optional attribute bonus. Usage: /rollstat [attribute] [optional max value]",
    arguments = {"[attribute]", "[max]"},
    format = "%s rolls %s",
    indicator = "roll",
    deadCanChat = true,
    CanHear = ix.config.Get("chatRange", 280),
    
    OnChatAdd = function(self, speaker, text)
        if not IsValid(speaker) then return end

        -- Split the input, expecting: [attribute] [optional max value]
        local parts = string.Explode(" ", text)
        local attributeInput = parts[1] and string.lower(parts[1]) or nil
        if not attributeInput then
            speaker:Notify("Invalid attribute! Usage: /rollstat [attribute] [optional max value]")
            return
        end

        local maxVal = 100
        if parts[2] then
            maxVal = tonumber(parts[2])
            if not maxVal or maxVal <= 0 then
                speaker:Notify("Invalid maximum value! It must be a positive number.")
                return
            end
        end

        local roll = math.random(1, maxVal)
        local bonus = 0
        local attributeKey = nil

        -- Automatically detect the attribute by iterating over ix.attributes.list.
        if speaker:GetCharacter() and ix.attributes and ix.attributes.list then
            for key, data in pairs(ix.attributes.list) do
                local keyLower  = string.lower(key)
                local dataNameLower = data.name and string.lower(data.name) or ""
                if string.find(keyLower, attributeInput, 1, true) or string.find(dataNameLower, attributeInput, 1, true) then
                    attributeKey = key
                    break
                end
            end
        end

        if not attributeKey then
            speaker:Notify("That is not a valid attribute!")
            return
        end

        bonus = speaker:GetCharacter():GetAttribute(attributeKey, 0) or 0
        local total = roll + bonus

        local displayAttribute = (ix.attributes.list[attributeKey] and ix.attributes.list[attributeKey].name) or
                                 (attributeKey:sub(1,1):upper() .. attributeKey:sub(2))
        local msg = ""
        if bonus > 0 then
            -- Even with bonus, display the roll as "out of maxVal"
            msg = string.format("rolls a %d out of %d (roll: %d, +%d bonus) for %s.", total, maxVal, roll, bonus, displayAttribute)
        else
            msg = string.format("rolls a %d out of %d for %s.", roll, maxVal, displayAttribute)
        end

        local chatColor = ix.config.Get("chatColor", Color(255,230,100))
        local factionColor = Color(255,255,255)
        if speaker:GetCharacter() and speaker:GetCharacter().GetFactionColor then
            factionColor = speaker:GetCharacter():GetFactionColor()
        end

        local name = hook.Run("GetCharacterName", speaker) or speaker:Name()
        chat.AddText(chatColor, "*** ", factionColor, name, chatColor, " " .. msg)
    end
})
