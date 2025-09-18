ITEM.name = "Mug-Only Bag"
ITEM.description = "A specialized bag that can only hold mugs."
ITEM.model = "models/props_junk/garbage_bag001a.mdl" -- Example model for a bag

-- Function to restrict items that can be transferred into the bag's inventory
function ITEM:CanItemBeTransferred(item, fromInv, toInv)
    -- Only allow items with the unique ID "mug" to be transferred into the bag
    if toInv == self:GetInventory() and item.uniqueID ~= "mug" then
        return false
    end
    return true
end