PLUGIN.name = "Magazine System"
PLUGIN.author = "copilot"
PLUGIN.desc = "Implements a magazine system for weapons with up to 5 equipped magazines and reload functionality."
PLUGIN.uniqueID = "magazines"

if SERVER then
    util.AddNetworkString("MagazineReloaded")
end
