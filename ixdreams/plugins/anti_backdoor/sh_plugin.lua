PLUGIN.name = "Anti Backdoor"
PLUGIN.author = ""

local tWhitelist = {
    "gm_construct",
    "gm_flagrass"
}

if table.HasValue( tWhitelist, game.GetMap() ) then return end

ix.util.Include( "sv_plugin.lua" )