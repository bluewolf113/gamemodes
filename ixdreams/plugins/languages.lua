-- plugins/languages/sh_plugin.lua
PLUGIN.name        = "Languages"
PLUGIN.author      = "Blue & Copilot"
PLUGIN.description = "Custom language chat identical to IC/W/Y with dynamic (language) tags and fuzzy name matching."

-- Supported languages (extend as needed)
local languageList = {
    -- Europe
    "Vortigese","Spanish","French","German","Russian","Italian","Portuguese","Dutch","Polish",
    "Ukrainian","Czech","Slovak","Hungarian","Bulgarian","Romanian","Serbian","Croatian",
    "Bosnian","Slovenian","Albanian","Greek","Turkish","Swedish","Norwegian","Danish",
    "Finnish","Estonian","Latvian","Lithuanian","Icelandic","Maltese",
    -- World (common)
    "Arabic","Hindi","Bengali","Mandarin Chinese","Cantonese Chinese","Japanese","Korean",
    "Persian","Swahili","Tamil","Telugu","Thai","Urdu","Vietnamese"
}

-- Case-insensitive + partial matching
local function MatchLanguage(input)
    if not input then return nil end
    local needle = string.lower(string.Trim(tostring(input)))
    if needle == "" then return nil end

    -- 1) exact
    for _, name in ipairs(languageList) do
        if string.lower(name) == needle then
            return name
        end
    end
    -- 2) prefix
    for _, name in ipairs(languageList) do
        if string.StartWith(string.lower(name), needle) then
            return name
        end
    end
    -- 3) substring
    for _, name in ipairs(languageList) do
        if string.find(string.lower(name), needle, 1, true) then
            return name
        end
    end
    return nil
end

-- Safe name color (schema-agnostic)
local function NameColor(ply)
    if ix and ix.faction and ix.faction.indices then
        local faction = ix.faction.indices[ply:Team()]
        if faction and faction.color then
            return faction.color
        end
    end
    local tc = team and team.GetColor and team.GetColor(ply:Team())
    if tc then return tc end
    return Color(255, 255, 255)
end

-- Commands

ix.command.Add("AddLanguage", {
    description = "Give a character a language (case-insensitive, partial allowed).",
    adminOnly   = true,
    arguments   = { ix.type.character, ix.type.text },
    OnRun       = function(self, client, targetChar, langInput)
        if not IsValid(client) or not targetChar then
            if IsValid(client) then client:Notify("Invalid target.") end
            return false
        end

        local matched = MatchLanguage(langInput)
        if not matched then
            client:Notify("Unknown language: " .. tostring(langInput))
            return false
        end

        local langs = targetChar:GetData("languages", {})
        if langs[matched] then
            client:Notify(targetChar:GetName() .. " already knows " .. matched .. ".")
            return true
        end

        langs[matched] = true
        targetChar:SetData("languages", langs)
        client:Notify("Added " .. matched .. " to " .. targetChar:GetName())
        return true
    end
})

ix.command.Add("RemoveLanguage", {
    description = "Remove a language from a character (partial/case-insensitive).",
    adminOnly   = true,
    arguments   = { ix.type.character, ix.type.text },
    OnRun       = function(self, client, targetChar, langInput)
        if not IsValid(client) or not targetChar then
            if IsValid(client) then client:Notify("Invalid target.") end
            return false
        end

        local matched = MatchLanguage(langInput)
        if not matched then
            client:Notify("Unknown language: " .. tostring(langInput))
            return false
        end

        local langs = targetChar:GetData("languages", {})
        if not langs[matched] then
            client:Notify(targetChar:GetName() .. " does not know " .. matched .. ".")
            return true
        end

        langs[matched] = nil
        targetChar:SetData("languages", langs)
        client:Notify("Removed " .. matched .. " from " .. targetChar:GetName())
        return true
    end
})

ix.command.Add("CheckLanguages", {
    description = "Show what languages a character knows.",
    arguments   = { ix.type.character },
    OnRun       = function(self, client, targetChar)
        if not IsValid(client) or not targetChar then return false end

        local langs = targetChar:GetData("languages", {})
        if not next(langs) then
            client:Notify(targetChar:GetName() .. " knows no languages.")
            return true
        end

        local out = {}
        for displayName, has in pairs(langs) do
            if has then out[#out+1] = displayName end
        end
        table.sort(out)
        client:Notify(targetChar:GetName() .. " knows: " .. table.concat(out, ", "))
        return true
    end
})

ix.command.Add("SetLanguage", {
    description = "Set your active language for speech (type 'none' to reset).",
    arguments   = { ix.type.text }, -- required
    OnRun       = function(self, client, langInput)
        if not IsValid(client) then return false end
        local char = client:GetCharacter()
        if not char then return false end

        local trimmed = string.Trim(langInput or "")
        if trimmed == "" or trimmed:lower() == "none" then
            char:SetData("activeLanguage", nil)
            client:Notify("Language reset.")
            return true
        end

        local matched = MatchLanguage(trimmed)
        if not matched then
            client:Notify("Unknown language: " .. trimmed)
            return false
        end

        local known = char:GetData("languages", {})
        if not known[matched] then
            client:Notify("You don't know " .. matched .. ".")
            return false
        end

        char:SetData("activeLanguage", matched) -- store display name
        client:Notify("Now speaking in " .. matched)
        return true
    end
})

-- Chat classes

ix.chat.Register("lang", {
    format   = "%s says in %s, \"%s\"",
    GetColor = function(self, speaker, text)
        return ix.chat.classes.ic:GetColor(speaker, text)
    end,
    CanHear  = function(self, speaker, listener)
        local range = ix.config.Get("chatRange", 280)
        return IsValid(speaker) and IsValid(listener)
            and listener:GetPos():DistToSqr(speaker:GetPos()) <= (range * range)
    end,
    CanSay   = function(self, speaker, text, data)
        local char = IsValid(speaker) and speaker:GetCharacter()
        return char and data and isstring(data.lang) and data.lang ~= ""
    end,
    OnChatAdd = function(self, speaker, text, anonymous, data)
        local lang    = data and data.lang or "Unknown"
        local knows   = data and data.knows
        local nameCol = NameColor(speaker)
        local textCol = ix.config.Get("chatColor", Color(255, 255, 255))

        if knows then
            chat.AddText(
                nameCol, speaker:Name(),
                textCol, " says in " .. lang .. ', "' .. text .. '"'
            )
        else
            chat.AddText(
                nameCol, speaker:Name(),
                textCol, " says something in " .. lang
            )
        end
    end
})

ix.chat.Register("lang_w", {
    format   = "%s whispers in %s, \"%s\"",
    GetColor = function(self, speaker, text)
        return ix.chat.classes.w:GetColor(speaker, text)
    end,
    CanHear  = function(self, speaker, listener)
        local range = ix.config.Get("chatRange", 90)
        return IsValid(speaker) and IsValid(listener)
            and listener:GetPos():DistToSqr(speaker:GetPos()) <= (range * range)
    end,
    CanSay   = function(self, speaker, text, data)
        local char = IsValid(speaker) and speaker:GetCharacter()
        return char and data and isstring(data.lang) and data.lang ~= ""
    end,
    OnChatAdd = function(self, speaker, text, anonymous, data)
        local lang    = data and data.lang or "Unknown"
        local knows   = data and data.knows
        local nameCol = NameColor(speaker)
        local textCol = ix.config.Get("chatColor", Color(255, 255, 255))

        if knows then
            chat.AddText(
                nameCol, speaker:Name(),
                textCol, " whispers in " .. lang .. ', "' .. text .. '"'
            )
        else
            chat.AddText(
                nameCol, speaker:Name(),
                textCol, " whispers something in " .. lang
            )
        end
    end
})

ix.chat.Register("lang_y", {
    format   = "%s yells in %s, \"%s\"",
    GetColor = function(self, speaker, text)
        return ix.chat.classes.y:GetColor(speaker, text)
    end,
    CanHear  = function(self, speaker, listener)
        local range = ix.config.Get("chatRange", 560)
        return IsValid(speaker) and IsValid(listener)
            and listener:GetPos():DistToSqr(speaker:GetPos()) <= (range * range)
    end,
    CanSay   = function(self, speaker, text, data)
        local char = IsValid(speaker) and speaker:GetCharacter()
        return char and data and isstring(data.lang) and data.lang ~= ""
    end,
    OnChatAdd = function(self, speaker, text, anonymous, data)
        local lang    = data and data.lang or "Unknown"
        local knows   = data and data.knows
        local nameCol = NameColor(speaker)
        local textCol = ix.config.Get("chatColor", Color(255, 255, 255))

        if knows then
            chat.AddText(
                nameCol, speaker:Name(),
                textCol, " yells in " .. lang .. ', "' .. text .. '"'
            )
        else
            chat.AddText(
                nameCol, speaker:Name(),
                textCol, " yells something in " .. lang
            )
        end
    end
})

-- Server-side routing: split recipients so non-speakers never receive the content
if SERVER then
    local function SplitRecipientsByKnowledge(speaker, text, lang, range)
        local pos = speaker:GetPos()
        local rangeSqr = range * range
        local knows, dont = {}, {}

        for _, ply in ipairs(player.GetAll()) do
            if IsValid(ply) and ply:Alive() and ply:GetPos():DistToSqr(pos) <= rangeSqr then
                local tch = ply:GetCharacter()
                if tch then
                    local langs = tch:GetData("languages", {})
                    if langs[lang] then
                        knows[#knows+1] = ply
                    else
                        dont[#dont+1] = ply
                    end
                end
            end
        end

        return knows, dont
    end

    function PLUGIN:PlayerSay(client, text, teamChat)
        if teamChat then return end
        if not IsValid(client) then return end

        local char = client:GetCharacter()
        if not char then return end

        local lang = char:GetData("activeLanguage")
        if not lang or lang == "" then
            -- No active language: let Helix handle default IC/W/Y
            return
        end

        local lower = string.lower(text or "")

        -- Whisper
        if string.StartWith(lower, "/w ") or string.StartWith(lower, "!w ") then
            local msg = string.sub(text, 4)
            if msg == "" then return "" end
            local range = ix.config.Get("chatRange", 90)
            local knows, dont = SplitRecipientsByKnowledge(client, msg, lang, range)
            if #knows > 0 then ix.chat.Send(client, "lang_w", msg, knows, nil, { lang = lang, knows = true }) end
            if #dont  > 0 then ix.chat.Send(client, "lang_w", "",  dont,  nil, { lang = lang, knows = false }) end
            return "" -- swallow default whisper
        end

        -- Yell
        if string.StartWith(lower, "/y ") or string.StartWith(lower, "!y ") then
            local msg = string.sub(text, 4)
            if msg == "" then return "" end
            local range = ix.config.Get("chatRange", 560)
            local knows, dont = SplitRecipientsByKnowledge(client, msg, lang, range)
            if #knows > 0 then ix.chat.Send(client, "lang_y", msg, knows, nil, { lang = lang, knows = true }) end
            if #dont  > 0 then ix.chat.Send(client, "lang_y", "",  dont,  nil, { lang = lang, knows = false }) end
            return "" -- swallow default yell
        end

        -- Plain IC (no slash): replace with language IC
        if not string.StartWith(lower, "/") and not string.StartWith(lower, "!") then
            local msg = text
            if msg == "" then return "" end
            local range = ix.config.Get("chatRange", 280)
            local knows, dont = SplitRecipientsByKnowledge(client, msg, lang, range)
            if #knows > 0 then ix.chat.Send(client, "lang", msg, knows, nil, { lang = lang, knows = true }) end
            if #dont  > 0 then ix.chat.Send(client, "lang", "",  dont,  nil, { lang = lang, knows = false }) end
            return "" -- swallow default IC
        end

        -- Any other slash-prefixed text => let Helix handle commands
    end
end


function PLUGIN:PopulateHelpMenu(tabs)
    tabs["languages"] = function(container)
        container:Clear()

        local scroll = container:Add("DScrollPanel")
        scroll:Dock(FILL)

        local header = scroll:Add("DLabel")
        header:SetFont("ixMediumFont")
        header:SetText("Supported Languages")
        header:Dock(TOP)
        header:SetTall(32)
        header:SetContentAlignment(5)

        local sorted = table.Copy(languageList)
        table.sort(sorted)

        for _, lang in ipairs(sorted) do
            local label = scroll:Add("DLabel")
            label:SetFont("ixSmallFont")
            label:SetText("- " .. lang)
            label:Dock(TOP)
            label:SetContentAlignment(5)
        end

        container.OnSizeChanged = function(_, newWidth, newHeight)
            scroll:SetSize(newWidth, newHeight)
        end
    end
end