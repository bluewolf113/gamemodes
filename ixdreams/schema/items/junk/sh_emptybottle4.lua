ITEM.base = "base_junk"

ITEM.name = "Empty Bottle"
ITEM.model = Model("models/willardnetworks/food/wine4.mdl")
ITEM.description = "An empty glass bottle."
ITEM.salvageDescription = "You break the bottle."
ITEM.category = "Junk"
ITEM.width = 1
ITEM.height = 1
ITEM.scrap = {["brokenglass"] =  {2, 4}}
ITEM.sounds = {"physics/glass/glass_bottle_break1.wav",
				"physics/glass/glass_bottle_break2.wav"}