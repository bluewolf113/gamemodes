ITEM.name = "Generic Key"
ITEM.description = "Generic Description"
ITEM.model = Model("models/items/keys_001.mdl")
ITEM.category = "Customise"
ITEM.isKey = true

function ITEM:GetName()
    return self:GetData("name", "Custom Item")
end

function ITEM:GetDescription()
    return self:GetData("description", "Custom item description.")
end

function ITEM:GetModel()
    return self:GetData("model", "models/items/keys_001.mdl")
end

function ITEM:GetKeyID()
    return self:GetData("keyID", "")
end
