
PLUGIN.name = "Radio"
PLUGIN.author = "SleepyMode"
PLUGIN.description = "Implements a functional radio system."

CAMI.RegisterPrivilege({
	Name = "Helix - Manage Radio",
	MinAccess = "admin"
})

ix.char.RegisterVar("radioChannel", {
	bNoDisplay = true
})

ix.config.Add("observerNoRadioEavesdrop", true, "Whether people using radio in observer will not be heard locally.", nil, {
	category = "Enhanced Radios"
})

ix.util.Include("sv_plugin.lua")
ix.util.Include("cl_plugin.lua")
ix.util.Include("sv_hooks.lua")
ix.util.Include("cl_hooks.lua")
ix.util.Include("sh_classes.lua")
ix.util.Include("sh_commands.lua")
ix.util.Include("sh_channels.lua")