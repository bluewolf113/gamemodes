ITEM.base = "base_food"

ITEM.name = "Watermelon Half"
ITEM.model = Model("models/foodnhouseholditems/watermelon_half.mdl")
ITEM.width = 2
ITEM.height = 2
ITEM.description = "Get descs"
ITEM.eat = "Yum."
ITEM.category = "Food"
ITEM.hunger = 5
ITEM.thirst = 10
ITEM.nutrition = 30
ITEM.uses = 6
ITEM.usesAlias = {"Bite", "Bites"}

ITEM.functions.combine = {
    OnRun = function(item, data)
        local targetItem = ix.item.instances[data[1]] -- this is the knife
        local player = item.player

        -- Remove this item (e.g., the watermelon)
        item:Remove()

        -- Give paper to the player
        local inv = player:GetCharacter():GetInventory()
            inv:Add("watermelonslice")
            inv:Add("watermelonslice")
            
        client:EmitSound("physics/flesh/flesh_squishy_impact_hard4.wav", 60, 100)

        return false -- the knife is kept
    end,

    OnCanRun = function(item, data)
        local targetItem = ix.item.instances[data[1]]

        -- Only allow combine if the target item is a knife
        return targetItem and targetItem.uniqueID == "bowieknife"
    end
}
