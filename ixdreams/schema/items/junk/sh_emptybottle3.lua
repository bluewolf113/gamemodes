ITEM.base = "base_junk"

ITEM.name = "Empty Glass Jug"
ITEM.model = Model("models/props_junk/glassjug01.mdl")
ITEM.description = "An empty glass jug."
ITEM.salvageDescription = "You break the jug."
ITEM.category = "Junk"
ITEM.width = 1
ITEM.height = 1
ITEM.scrap = {["brokenglass"] =  {5, 7}}
ITEM.sounds = {"physics/glass/glass_bottle_break1.wav",
				"physics/glass/glass_bottle_break2.wav"}