--[[
        © Asterion Project 2021.
        This script was created from the developers of the AsterionTeam.
        You can get more information from one of the links below:
            Site - https://asterionproject.ru
            Discord - https://discord.gg/Cz3EQJ7WrF
        
        developer(s):
            Selenter - https://steamcommunity.com/id/selenter

        ——— Chop your own wood and it will warm you twice.
]]--

local PLUGIN = PLUGIN

PLUGIN.name = "EasyESP"
PLUGIN.author = "AsterionTeam"
PLUGIN.description = ""

PLUGIN.playerinfo = {}
PLUGIN.entityinfo = {}

PLUGIN.entslist = {
    ["ix_item"] = Color(157, 111, 210),
    ["ix_vendor"] = Color(197, 199, 62),
    ["ix_container"] = Color(41, 175, 34),
	["ix_fluidsource"] = Color(76, 138, 255),
	["ix_cookingsource"] = Color(255, 76, 76),
	["ix_hint"] = Color(255, 255, 255)
}

if CLIENT then
    PLUGIN.mat = PLUGIN.mat or CreateMaterial("deznutz", "VertexLitGeneric", {
        ["$basetexture"] = "models/debug/debugwhite",
        ["$model"] = 1,
        ["$ignorez"] = 1
    })
end

local function addLang(name, index, data)
    if data.config and ix.lang.stored then
        data.config.index = index

        local c_index = "AdminESP_" .. index
        local c_name = "opt" .. c_index
        local c_desc = "optd" .. c_index

        local newindex = index
        newindex = newindex:gsub("_pl", "")
        newindex = newindex:gsub("_en", "")

        for k, v in pairs(ix.lang.stored) do
            ix.lang.stored[k][c_name] = data.config.name .. " [" .. newindex .. "]"
            ix.lang.stored[k][c_desc] = data.config.desc
        end

        ix.option.Add(c_index, ix.type.bool, true, {
            category = "AdminESP" .. " " .. name,
            hidden = function()
                return !LocalPlayer():IsAdmin()
            end
        })
    end
end

function PLUGIN:IsWhitelistedEntity(entity)
	return PLUGIN.entslist[entity]
end

function PLUGIN:AddPlayerESPCustomization(index, data)
    if !index then return end
    if !data then return end

    data.index = index
    self.playerinfo[#self.playerinfo + 1] = data

    addLang("Player", index, data)
end

function PLUGIN:AddEntityESPCustomization(index, data)
    if !index then return end
    if !data then return end

    data.index = index
    self.entityinfo[#self.entityinfo + 1] = data

    addLang("Entity", index, data)
end

function PLUGIN:DistanceFits(vec1, vec2, dist)
    if dist == 0 then return true end

    return vec1:Distance(vec2) <= dist
end

local function addStructure(entity, dist, data, settings)
    if isfunction(data) and PLUGIN:DistanceFits(LocalPlayer():GetPos(), entity:GetPos(), dist) then
        if settings and settings.index then
            if ix.option.Get("AdminESP_" .. settings.index, true) then
                data = data(entity)
            else
                data = nil
            end
        else
            data = data(entity)
        end
    end

    return {data, dist, entity:GetClass()}
end

local metaPl = FindMetaTable("Player")
function metaPl:ESPInfo()
    local data = {}

    for k, v in SortedPairs(PLUGIN.playerinfo) do
        data[#data + 1] = addStructure(self, v.dist, v.data, v.config)
    end

    return data
end

local metaEn = FindMetaTable("Entity")
function metaEn:ESPInfo()
    local data = {}

    for k, v in SortedPairs(PLUGIN.entityinfo) do
        data[#data + 1] = addStructure(self, v.dist, v.data, v.config)
    end

    return data
end

ix.util.Include("cl_config.lua")
ix.util.Include("cl_plugin.lua")
