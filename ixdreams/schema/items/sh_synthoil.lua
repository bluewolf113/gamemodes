ITEM.base = "base_drink"

ITEM.name = "Synth Oil"
ITEM.model = Model("models/props_lab/jar01b.mdl")
ITEM.description = "Lymph gunk pressed from the carcass of a Combine Strider."
ITEM.drink = "Somehow you can taste them all, every fight, every wail."
ITEM.category = "Drugs"
ITEM.uses = 12
ITEM.thirst = 0.5
ITEM.itx_synthoil =  5
ITEM.junk = {["emptyjar1"] =  1}

function ITEM:GetStatusEffects()
	local statsTbl = {}
	
	statsTbl["itx_synthoil"] = self.itx_synthoil
	
	return statsTbl
end