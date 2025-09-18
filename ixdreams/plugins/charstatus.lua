
local PLUGIN = PLUGIN

PLUGIN.name = "Character Status"
PLUGIN.author = "Gary Tate"
PLUGIN.description = "Allows player to display their character's status."

ix.lang.AddTable("english", {
    charNotifySetStatus         = "You have set your status to: '%s'",
    charNotifyRemoveStatus      = "You have removed your status.",
    charAdminNotifySetStatus    = "%s has set %s's status to: '%s'",
    charAdminNotifyRemoveStatus = "%s has removed %s's status.",
    cmdCharSetStatus            = "Set your character status.",
    cmdCharRemoveStatus         = "Remove your character status.",
    cmdCharAdminSetStatus       = "Set a character's status.",
    cmdCharAdminRemoveStatus    = "Remove a character's status.",
})

PLUGIN.colorTable = {
    red   = Color(255, 0, 0),
    blue  = Color(0, 0, 255),
    green = Color(0, 255, 0),
    white = Color(255, 255, 255)
}

ix.char.RegisterVar("CharStatus", {
    bNoNetworking = false,
    bNoDisplay = true,
    fieldType = ix.type.text,
    default = {}
})

if (SERVER) then
    ix.log.AddType("charSetStatus", function(client, status)
        return string.format("%s has set their status to: '%s'", client:Name(), status)
    end)

    ix.log.AddType("charRemoveStatus", function(client)
        return string.format("%s has removed their status.", client:Name())
    end)

    ix.log.AddType("charAdminSetStatus", function(client, target, status)
        return string.format("%s has set %s's status to: '%s'", client:Name(), target:Name(), status)
    end)

    ix.log.AddType("charAdminRemoveStatus", function(client, target)
        return string.format("%s has removed %s's status.", client:Name(), target:Name())
    end)

    function PLUGIN:CharacterLoaded(character)
        local statusInfo = character:GetData("CharStatus", {})

        if (#statusInfo > 0) then
            character:SetCharStatus(statusInfo)
        end
    end

    -- Hooks
    function PLUGIN:CanEditStatus(client)
    end
else
    function PLUGIN:PopulateCharacterInfo(client, character, tooltip)
        local statusInfo = character:GetCharStatus()

        if (statusInfo and #statusInfo > 0) then
            local color = self.colorTable[statusInfo[1]:utf8lower()] or Color(255, 255, 255)

            local panel = tooltip:AddRowAfter("name", "charstatus")
            panel:SetBackgroundColor(color)
            panel:SetText(statusInfo[2] or "Error displaying character status")
            panel:SizeToContents()
        end
    end
end

do
    -- CharSetStatus
    local COMMAND = {
        description = "@cmdCharSetStatus",
        arguments = {
            bit.bor(ix.type.string, ix.type.optional),
            bit.bor(ix.type.string, ix.type.optional)
        }
    }

    function COMMAND:OnCheckAccess(client)
        return hook.Run("CanEditStatus", client) or true
    end

    function COMMAND:OnRun(client, status, color)
        color = color or "white"

        local character = client:GetCharacter()

        if (character) then
            character:SetCharStatus({color, status})
            character:SetData("CharStatus", {color, status})

            client:NotifyLocalized("charNotifySetStatus", status)
        end

        ix.log.Add(client, "charSetStatus", status)
    end

    ix.command.Add("CharSetStatus", COMMAND)

    -- CharRemoveStatus
    COMMAND = {
        description = "@cmdCharRemoveStatus"
    }

    function COMMAND:OnCheckAccess(client)
        return hook.Run("CanEditStatus", client) or true
    end

    function COMMAND:OnRun(client)
        local character = client:GetCharacter()

        if (character) then
            character:SetCharStatus(nil)
            character:SetData("CharStatus", nil)

            client:NotifyLocalized("charNotifyRemoveStatus")
        end

        ix.log.Add(client, "charRemoveStatus")
    end

    ix.command.Add("CharRemoveStatus", COMMAND)

    -- CharAdminSetStatus
    local COMMAND = {
        description = "@cmdCharAdminSetStatus",
        adminOnly = true,
        arguments = {
            ix.type.character,
            bit.bor(ix.type.string, ix.type.optional),
            bit.bor(ix.type.string, ix.type.optional)
        }
    }

    function COMMAND:OnRun(client, target, status, color)
        local targetPlayer = target:GetPlayer()
        color = color or "green"

        local rgbcolor = PLUGIN.colorTable[color:utf8lower()]

        target:SetCharStatus({color, status})
        target:SetData("CharStatus", {color, status})

        for _,v in ipairs(player.GetAll()) do
            if (v == client or v == targetPlayer or self:OnCheckAccess(v)) then
                v:NotifyLocalized("charAdminNotifySetStatus", client:Name(), targetPlayer:Name(), status)
            end
        end

        ix.log.Add(client, "charAdminSetStatus", targetPlayer:Name(), status)
    end

    ix.command.Add("CharAdminSetStatus", COMMAND)

    -- CharAdminRemoveStatus
    COMMAND = {
        description = "@cmdCharAdminRemoveStatus",
        adminOnly = true,
        arguments = {
            ix.type.character
        }
    }

    function COMMAND:OnRun(client, target)
        local targetPlayer = target:GetPlayer()

        target:SetCharStatus({})
        target:SetData("CharStatus", {})

        for _,v in ipairs(player.GetAll()) do
            if (v == client or v == targetPlayer or self:OnCheckAccess(v)) then
                v:NotifyLocalized("charAdminNotifyRemoveStatus", client:Name(), targetPlayer:Name())
            end
        end

        ix.log.Add(client, "charAdminRemoveStatus")
    end

    ix.command.Add("CharAdminRemoveStatus", COMMAND)
end
