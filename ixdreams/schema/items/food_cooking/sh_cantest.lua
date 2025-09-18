ITEM.base = "base_food_cooking"

ITEM.name = "Can Test"
ITEM.model = Model("models/lostsignalproject/items/consumable/chili.mdl")
ITEM.width = 1
ITEM.height = 1
ITEM.description = "Chili."
ITEM.eat = "Yum."
ITEM.eatCooked = "Very filling, and heavy with sour fat."
ITEM.category = "Food"
ITEM.hunger = 14
ITEM.uses = 4

ITEM.functions.combine = {
  OnRun = function(item, data)
    local knife  = ix.item.instances[data[1]]
    local player = item.player
    local inv    = player:GetCharacter():GetInventory()

    -- 1) Get the *real* grid position:
    local x, y = item.gridX, item.gridY
    if not x or not y then
      player:Notify("Couldn't find the can's spot in your inventory.")
      return false
    end

    -- Debug log—uncomment to see in console
    -- print("Opening can at:", x, y)

    -- 2) Remove the original item
    item:Remove()

    -- 3) Place the half-baguette back into the same slot
    inv:Add("baugettehalf", 1, nil, x, y)

    -- 4) Play sound on *player*, not “client”
    player:EmitSound("physics/flesh/flesh_squishy_impact_hard4.wav", 20, 100)

    return false
  end,

  OnCanRun = function(item, data)
    local knife = ix.item.instances[data[1]]
    return knife and knife.uniqueID == "bowieknife"
  end
}
