ITEM.name = "Flashlight"
ITEM.model = Model("models/willardnetworks/skills/flashlight.mdl")
ITEM.width = 1
ITEM.height = 1
ITEM.description = "A sturdy flashlight with a long battery life."
ITEM.category = "Equipment"

ITEM:Hook("drop", function(item, data)
	item.player:Flashlight(false)
end)