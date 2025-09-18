ITEM.base = "base_junk"

ITEM.name = "Rusty Rifle"
ITEM.model = Model("models/weapons/w_rif_m4a1.mdl")
ITEM.description = "An old rifle rusted beyond repair."
ITEM.salvageDescription = "You smash the can."
ITEM.category = "Junk"
ITEM.width = 3
ITEM.height = 1

function ITEM:GetMaterial()
	return "models/props_pipes/destroyedpipes01a"
end