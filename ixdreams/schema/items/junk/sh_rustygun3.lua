ITEM.base = "base_junk"

ITEM.name = "Rusty Shotgun"
ITEM.model = Model("models/weapons/w_shot_xm1014.mdl")
ITEM.description = "An old shotgun rusted beyond repair."
ITEM.salvageDescription = "You smash the can."
ITEM.category = "Junk"
ITEM.width = 3
ITEM.height = 1

function ITEM:GetMaterial()
	return "models/props_pipes/destroyedpipes01a"
end