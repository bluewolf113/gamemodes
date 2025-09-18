ITEM.base = "base_drink"

ITEM.name = "Beer (Homebrew)"
ITEM.model = Model("models/props/cs_militia/bottle01.mdl")
ITEM.description = "An unbranded, fresh-brewed bottle of beer."
ITEM.drink = "Warms your blood, tasting of lightning and bad soil while it does."
ITEM.category = "Drink"
ITEM.thirst = 4
ITEM.uses = 6
ITEM.drunk = 3
ITEM.junk = {["emptybottle1"] =  1}

function ITEM:GetStatusEffects()
	local statsTbl = {}
	
	statsTbl["drunk"] = self.drunk
	
	return statsTbl
end