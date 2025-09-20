ITEM.base = "base_food"

ITEM.name = "Halved Bread Loaf"
ITEM.model = Model("models/goudin/stalker_pack/food/bread_06.mdl")
ITEM.width = 2
ITEM.height = 1
ITEM.description = "wow."
ITEM.useText = "Eat"
ITEM.eat = "Hm"
ITEM.category = "Food"
ITEM.hunger = 3
ITEM.thirst = 0
ITEM.nutrition = 30
ITEM.uses = 4
ITEM.usesAlias = {"Bite", "Bites"}

ITEM.functions.combine = {
    OnRun = function(item, data)
        local targetItem = ix.item.instances[data[1]] -- this is the knife
        local player = item.player

        -- Remove this item (e.g., the watermelon)
        item:Remove()

        -- Give paper to the player
        local inv = player:GetCharacter():GetInventory()
            inv:Add("breadslice")
            inv:Add("breadslice")
            inv:Add("breadslice")
            
        client:EmitSound("physics/flesh/flesh_squishy_impact_hard4.wav", 60, 100)

        return false -- the knife is kept
    end,

    OnCanRun = function(item, data)
        local targetItem = ix.item.instances[data[1]]

        -- Only allow combine if the target item is a knife
        return targetItem and targetItem.uniqueID == "bowieknife"
    end
}