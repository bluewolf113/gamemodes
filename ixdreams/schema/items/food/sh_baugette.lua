ITEM.base = "base_food"

ITEM.name = "Baugette"
ITEM.model = Model("models/foodnhouseholditems/bread_loaf.mdl")
ITEM.width = 1
ITEM.height = 1
ITEM.description = "wow."
ITEM.eat = "."
ITEM.category = "Food"
ITEM.hunger = 4
ITEM.thirst = 3
ITEM.nutrition = 30
ITEM.uses = 2

ITEM.functions.combine = {
    OnRun = function(item, data)
        local targetItem = ix.item.instances[data[1]] -- this is the knife
        local player = item.player

        -- Remove this item (e.g., the watermelon)
        item:Remove()

        -- Give paper to the player
        local inv = player:GetCharacter():GetInventory()
            inv:Add("baugettehalf")
            inv:Add("baugettehalf")
            
        client:EmitSound("physics/flesh/flesh_squishy_impact_hard4.wav", 60, 100)

        return false -- the knife is kept
    end,

    OnCanRun = function(item, data)
        local targetItem = ix.item.instances[data[1]]

        -- Only allow combine if the target item is a knife
        return targetItem and targetItem.uniqueID == "bowieknife"
    end
}