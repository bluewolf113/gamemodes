ITEM.base = "base_drink"

ITEM.name = "Whiskey (Homebrew)"
ITEM.model = Model("models/props_junk/glassjug01.mdl")
ITEM.width = 1
ITEM.height = 1
ITEM.description = "A glass jug of experimental whiskey."
ITEM.drink = "You can barely get it into you."
ITEM.category = "Drink"
ITEM.thirst = -0.1
ITEM.uses = 16
ITEM.drunk = 20
ITEM.junk = {["emptybottle3"] =  1}

function ITEM:GetStatusEffects()
	local statsTbl = {}
	
	statsTbl["drunk"] = self.drunk
	
	return statsTbl
end