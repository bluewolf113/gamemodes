ITEM.base = "base_food"

ITEM.name = "Toast"
ITEM.model = Model("models/goudin/stalker_pack/food/bread_07.mdl")
ITEM.width = 1
ITEM.height = 1
ITEM.description = "wow."
ITEM.useText = "Eat"
ITEM.eat = "Hm"
ITEM.category = "Food"
ITEM.hunger = 4
ITEM.thirst = -1
ITEM.nutrition = 30
ITEM.uses = 2
ITEM.usesAlias = {"Bite", "Bites"}

function ITEM:GetMaterial()
    return "models/props_pipes/GutterMetal01a"
end