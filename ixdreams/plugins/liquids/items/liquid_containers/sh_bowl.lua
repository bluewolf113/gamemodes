
ITEM.name = "Bowl";
ITEM.model = "models/mosi/fallout4/props/junk/bowl.mdl";
ITEM.width	= 2
ITEM.height	= 3
ITEM.description = "The solution and the problem."
ITEM.category = "Containers"
ITEM.capacity = 300

-- Random skin between 1 and 4 on spawn
function ITEM:OnInstanced(invID, x, y, data)
    data = data or {}
    data.skin = math.random(1, 4)
    return data
end

-- Apply the skin when the item is spawned into the world
function ITEM:OnEntityCreated(entity)
    local data = self:GetData("skin", 1)
    entity:SetSkin(data)
end

