--[[

        © Asterion Project 2021.

        This script was created from the developers of the AsterionTeam.

        You can get more information from one of the links below:

            Site - https://asterionproject.ru

            Discord - https://discord.gg/Cz3EQJ7WrF

        

        developer(s):

            Selenter - https://steamcommunity.com/id/selenter



        ——— Chop your own wood and it will warm you twice.

]]

--

local PLUGIN = PLUGIN



--[[

    Players

]]

--

PLUGIN:AddPlayerESPCustomization("name_pl", {

    dist = 0,

    config = {

        name = "Character Name",

        desc = "The name of the player's character.",

    },

    data = function(entity) return entity:Name() end

})



PLUGIN:AddPlayerESPCustomization("steamname_pl", {

    dist = 0,

    config = {

        name = "Steam Name",

        desc = "The Steam name of a player.",

    },

    data = function(entity) return entity:SteamName() end

})



PLUGIN:AddPlayerESPCustomization("rank_pl", {

    dist = 1500,

    config = {

        name = "Usergroup",

        desc = "The usergroup of a player.",

    },

    data = function(entity) return entity:GetUserGroup() end

})



PLUGIN:AddPlayerESPCustomization("faction_pl", {

    dist = 1500,

    config = {

        name = "Faction",

        desc = "The faction of the character.",

    },

    data = function(entity) return ix.faction.indices[entity:Team()].name end

})



PLUGIN:AddPlayerESPCustomization("hp_armor_pl", {

    dist = 1000,

    config = {

        name = "Health & Armor",

        desc = "The health and armor of a player.",

    },

    data = function(entity) return entity:Health() .. "/" .. entity:Armor() end

})



PLUGIN:AddPlayerESPCustomization("weapon_pl", {

    dist = 1000,

    config = {

        name = "Weapon",

        desc = "The currently equipped weapon of a player.",

    },

    data = function(entity)

        local weapon = entity:GetActiveWeapon()

        if weapon and IsValid(weapon) then return weapon:GetPrintName() .. "[" .. weapon:GetClass() .. "] — " .. weapon:Clip1() .. "/" .. entity:GetAmmoCount(weapon:GetPrimaryAmmoType()) end

    end

})



PLUGIN:AddPlayerESPCustomization("vector_pl", {

    dist = 500,

    config = {

        name = "Vector",

        desc = "The vector of a player",

    },

    data = function(entity) return "Vector(" .. math.Round(entity:GetPos().x, 2) .. ", " .. math.Round(entity:GetPos().y, 2) .. ", " .. math.Round(entity:GetPos().z, 2) .. ")" end

})



PLUGIN:AddPlayerESPCustomization("dist_pl", {

    dist = 0,

    config = {

        name = "Distance",

        desc = "The distance of a player.",

    },

    data = function(entity) return math.Round(LocalPlayer():GetPos():Distance(entity:GetPos()), 1) end

})



PLUGIN:AddPlayerESPCustomization("chams_pl", {

    dist = 1000,

    config = {

        name = "Player Overlay",

        desc = "An overlay that highlights the player.",

    },

    data = function(entity)

        local col = team.GetColor(entity:Team())

        cam.Start3D(EyePos(), EyeAngles())

        render.SuppressEngineLighting(true)

        render.MaterialOverride(PLUGIN.mat)

        render.SetColorModulation(col.r / 255, col.g / 255, col.b / 255)

        entity:DrawModel()

        render.MaterialOverride()

        render.SuppressEngineLighting(false)

        cam.End3D()

    end

})



PLUGIN:AddPlayerESPCustomization("trace_pl", {

    dist = 1000,

    config = {

        name = "Trace Position",

        desc = "The trace position of a player.",

    },

    data = function(entity)

        local col = team.GetColor(entity:Team())

        local tr = {}

        tr.start = entity:EyePos()

        tr.endpos = (entity:GetAimVector() * 99999)



        tr.filter = {entity}



        local trace = util.TraceLine(tr).HitPos

        surface.SetDrawColor(col)



        if trace:ToScreen().visible and entity:EyePos():ToScreen().visible then

            surface.DrawLine(entity:EyePos():ToScreen().x, entity:EyePos():ToScreen().y, trace:ToScreen().x, trace:ToScreen().y)

        end



        surface.DrawRect(trace:ToScreen().x - 2.5, trace:ToScreen().y - 2.5, 5, 5)

    end

})



PLUGIN:AddPlayerESPCustomization("observer_pl", {

    dist = 0,

    config = {

        name = "Observer Mode",

        desc = "Toggles the observer mode.",

    },

    data = function(entity)

        if entity:GetMoveType() == MOVETYPE_NOCLIP then return "[OBSERVER]" end

    end

})



--[[

    Entity

]]

--

PLUGIN:AddEntityESPCustomization("name_en", {

    dist = 3000,

    config = {

        name = "Entity Name",

        desc = "The name of an entity.",

    },

    data = function(entity)

        if entity:GetClass() == "ix_item" then

            local itemTable = entity:GetItemTable()

            local itemname = itemTable:GetName()



            return itemname

        elseif entity:GetClass() == "ix_vendor" then

            local name = entity:GetDisplayName()



            return name

        elseif entity:GetClass() == "ix_container" then

            local name = entity:GetDisplayName()



            return name

        elseif PLUGIN:IsWhitelistedEntity(entity) then

            local name = entity.PrintName



            return name

        end

    end

})



PLUGIN:AddEntityESPCustomization("class_en", {

    dist = 1000,

    config = {

        name = "Class Name",

        desc = "The class name of an entity.",

    },

    data = function(entity) return entity:GetClass() end

})



PLUGIN:AddEntityESPCustomization("triggerinfo_en", {

    dist = 512,

    config = {

        name = "Trigger Info",

        desc = "The information of trigger entities.",

    },

    data = function(entity)

        if (entity.IsTrigger and entity.ExtendedTrigger) then

            local state = (entity:GetEnabled() and "1") or "0"

            local initState = (entity:GetInitialState() and "1") or "0"

            local eventKey = entity:GetNetVar("eventKey", "NULL")

            local nextEventKey = (entity:GetNextEventKey() and entity:GetNextEventKey()) or "nil"

            local eventName = (entity:GetEventName() and entity:GetEventName()) or "nil"



            return "[IO: " .. state .. " | Init: " .. initState .. " | Key: " .. eventKey .. " | Next Key: " .. nextEventKey .. " | Event: " .. eventName .. "]"

        elseif (entity.IsTrigger) then

            local state = (entity:GetEnabled() and "1") or "0"

            local initState = (entity:GetInitialState() and "1") or "0"

            local eventKey = entity:GetNetVar("eventKey", "NULL")



            return "[IO: " .. state .. " | Init: " .. initState .. " | Key: " .. eventKey .. "]"

        end

    end

})



PLUGIN:AddEntityESPCustomization("hp_en", {

    dist = 1000,

    config = {

        name = "Entity Health",

        desc = "The health of an entity.",

    },

    data = function(entity) return entity:Health() .. "/" .. entity:GetMaxHealth() end

})



PLUGIN:AddEntityESPCustomization("model_en", {

    dist = 200,

    config = {

        name = "Entity Model",

        desc = "The model of an entity.",

    },

    data = function(entity) return entity:GetModel() end

})



PLUGIN:AddEntityESPCustomization("vector_en", {

    dist = 500,

    config = {

        name = "Entity Vector",

        desc = "The vector of an entity",

    },

    data = function(entity) return "Vector(" .. math.Round(entity:GetPos().x, 2) .. ", " .. math.Round(entity:GetPos().y, 2) .. ", " .. math.Round(entity:GetPos().z, 2) .. ")" end

})



PLUGIN:AddEntityESPCustomization("chams_en", {

    dist = 1000,

    config = {

        name = "Entity Overlay",

        desc = "An overlay that highlights the entity.",

    },

    data = function(entity)

        local col = PLUGIN.entslist[entity:GetClass()] or Color(255, 255, 255)

        cam.Start3D(EyePos(), EyeAngles())

        render.SuppressEngineLighting(true)

        render.MaterialOverride(PLUGIN.mat)

        render.SetColorModulation(col.r / 255, col.g / 255, col.b / 255)

        entity:DrawModel()

        render.MaterialOverride()

        render.SuppressEngineLighting(false)

        cam.End3D()

    end

})