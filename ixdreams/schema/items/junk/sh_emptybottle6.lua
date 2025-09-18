ITEM.base = "base_junk"

ITEM.name = "Empty Bottle"
ITEM.model = Model("models/props_junk/garbage_glassbottle002a.mdl")
ITEM.description = "An empty glass bottle."
ITEM.salvageDescription = "You break the bottle."
ITEM.category = "Junk"
ITEM.width = 1
ITEM.height = 1
ITEM.scrap = {["brokenglass"] =  {1, 3}}
ITEM.sounds = {"physics/glass/glass_bottle_break1.wav",
				"physics/glass/glass_bottle_break2.wav"}