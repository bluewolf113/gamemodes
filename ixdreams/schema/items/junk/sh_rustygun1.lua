ITEM.base = "base_junk"

ITEM.name = "Rusty Handgun"
ITEM.model = Model("models/weapons/w_pist_glock18.mdl")
ITEM.description = "An old handgun rusted beyond repair."
ITEM.salvageDescription = "You smash the can."
ITEM.category = "Junk"
ITEM.width = 1
ITEM.height = 1

function ITEM:GetMaterial()
	return "models/props_pipes/destroyedpipes01a"
end