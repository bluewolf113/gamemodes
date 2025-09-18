--[[
	© 2020 TERRANOVA do not share, re-distribute or modify
	without permission of its author.
--]]

PLUGIN.name = "Vortigaunts";
PLUGIN.description = "Adds vortigaunts and other features relevant for them.";
PLUGIN.author = "Adolphus";

ix.util.Include("sv_hooks.lua")
ix.util.Include("cl_hooks.lua")
ix.util.Include("sh_hooks.lua")
ix.util.IncludeDir(PLUGIN.folder .. "/commands", true)
ix.util.IncludeDir(PLUGIN.folder .. "/meta", true)
ix.anim.SetModelClass("models/terranovavortigaunt.mdl", "vortigaunt")
ix.anim.SetModelClass("models/terranovavortigauntslave.mdl", "vortigaunt")
ix.anim.SetModelClass("models/vortigaunt.mdl", "vortigaunt")
ix.anim.SetModelClass("models/vortigaunt_blue.mdl", "vortigaunt")
ix.anim.SetModelClass("models/vortigaunt_doctor.mdl", "vortigaunt")
ix.anim.SetModelClass("models/vortigaunt_slave.mdl", "vortigaunt")

ALWAYS_RAISED["swep_vortigaunt_sweep"] = true
ALWAYS_RAISED["swep_vortigaunt_heal"] = true

ix.config.Add("VortHealMin", 5, "Minimum health value that can be healed by vortigaunt" , nil, {
	data = {min = 1, max = 100},
	category = "Vortigaunt Healing Swep"
})

ix.config.Add("VortHealMax", 20, "Maximum health value that can be healed by vortigaunt" , nil, {
	data = {min = 1, max = 100},
	category = "Vortigaunt Healing Swep"
})

ix.command.Add("DebugClass", {
    description = "Prints your current class name and uniqueID to chat for debugging.",
    adminOnly = true,
    arguments = { bit.bor(ix.type.character, ix.type.optional) }, -- optional target

    OnRun = function(self, client, targetChar)
        local char = targetChar or client:GetCharacter()
        if not char then
            return "No character loaded."
        end

        local classIndex = char:GetClass()
        local classTable = ix.class.list[classIndex]

        if classTable then
            client:ChatPrint(
                string.format(
                    "[DEBUG] Class: %s (uniqueID: %s, index: %d)",
                    classTable.name,
                    classTable.uniqueID,
                    classIndex
                )
            )
        else
            client:ChatPrint("[DEBUG] No class assigned.")
        end
    end
})