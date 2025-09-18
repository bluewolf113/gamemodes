--[[
    Copyright (c) 2022 Cataclysm-HL2RP. Proprietary and confidential.
    Unauthorized copying of these files, via any medium is strictly prohibited.
    Do not share, re-distribute or modify without permission.
]]

local PLUGIN = PLUGIN
PLUGIN.name = "Offline Flags"
PLUGIN.author = "itz_sarah"
PLUGIN.description = "Get/set a character's flags while offline."

function PLUGIN:IsCharacterLoaded(id)
    return ix.char.loaded[tonumber(id)]
end

function PLUGIN:GetCharacter(client, character, steamID64, callback)
    local query = mysql:Select("ix_characters")
    query:Select("data")
    query:Select("id")
    query:Where("schema", Schema.folder)
    query:Where("name", character)
    query:Where("steamID", steamID64)

    query:Callback(function(result)
        if (result) then
            if (#result == 1) then
                callback(result[1].data, result[1].id)
            else
                client:Notify("OverloadedResult")
            end
        else
            client:Notify("NoResult")
        end
    end)

    query:Execute()
end

ix.command.Add("CharGetOfflineFlags", {
    description = "Get an offline character's flags.",
    adminOnly = true,
    arguments = {ix.type.string, ix.type.string},
    OnRun = function(self, client, steamID32, character)
        local steamID64 = util.SteamIDTo64(steamID32)

        PLUGIN:GetCharacter(client, character, steamID64, function(data, id)
            if (id and PLUGIN:IsCharacterLoaded(id)) then
                client:Notify("CharOnline", character)

                return
            end

            if (data and id) then
                local dataTable = util.JSONToTable(data)

                if dataTable.f then
                    client:Notify("Flags: " .. dataTable.f)
                else
                    client:Notify("<No flags>")
                end
            end
        end)
    end
})

ix.command.Add("CharSetOfflineFlags", {
    description = "Set an offline character's flags.",
    adminOnly = true,
    arguments = {
        ix.type.string,
        ix.type.string,
        ix.type.string
    },
    OnRun = function(self, client, steamID32, character, flags)
        local steamID64 = util.SteamIDTo64(steamID32)

        PLUGIN:GetCharacter(client, character, steamID64, function(data, id)
            if (id and PLUGIN:IsCharacterLoaded(id)) then
                client:Notify("CharOnline", character)

                return
            end

            if (data and id) then
                local dataTable = util.JSONToTable(data)
                dataTable.f = flags
                local query = mysql:Update("ix_characters")
                    query:Update("data", util.TableToJSON(dataTable))
                    query:Where("schema", Schema.folder)
                    query:Where("id", id)
                query:Execute()
                client:Notify("Flags set to: " .. dataTable.f)
            end
        end)
    end
})

ix.command.Add("CharRemoveAllOfflineFlags", {
    description = "Remove all of an offline character's flags.",
    adminOnly = true,
    arguments = {
        ix.type.string,
        ix.type.string
    },
    OnRun = function(self, client, steamID32, character)
        local steamID64 = util.SteamIDTo64(steamID32)

        PLUGIN:GetCharacter(client, character, steamID64, function(data, id)
            if (id and PLUGIN:IsCharacterLoaded(id)) then
                client:Notify("CharOnline", character)

                return
            end

            if (data and id) then
                local dataTable = util.JSONToTable(data)
                dataTable.f = nil
                local query = mysql:Update("ix_characters")
                    query:Update("data", util.TableToJSON(dataTable))
                    query:Where("schema", Schema.folder)
                    query:Where("id", id)
                query:Execute()
                client:Notify("All flags removed.")
            end
        end)
    end
})

