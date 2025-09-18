ITEM.base = "base_drink"

ITEM.name = "Beer (Expired)"
ITEM.model = Model("models/props_junk/glassbottle01a.mdl")
ITEM.description = "A bottle of beer brewed and forgotten years ago."
ITEM.drink = "You were better off leaving this in the bottle."
ITEM.category = "Drink"
ITEM.thirst = 2
ITEM.uses = {["init"] = {2, 6}}
ITEM.drunk = 1
ITEM.junk = {["emptybottle2"] =  1}

function ITEM:GetStatusEffects()
	local statsTbl = {}
	
	statsTbl["drunk"] = self.drunk
	
	return statsTbl
end
