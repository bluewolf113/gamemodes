ITEM.name = "Custom Outfit"
ITEM.description = "A unique outfit."
ITEM.model = Model("models/props_c17/BriefCase001a.mdl")
ITEM.category = "Outfit"
ITEM.outfitCategory = "body"

-- Pull from saved data
function ITEM:GetName()
    return self:GetData("name", "Custom Outfit")
end

function ITEM:GetDescription()
    return self:GetData("description", "A one-of-a-kind outfit.")
end

function ITEM:GetModel()
    return self:GetData("model", self.model)
end

-- Outfit replacement support
function ITEM:GetReplacement()
    return self:GetData("replacement", nil)
end

function ITEM:OnEquipped()
    local ply = self.player
    if not IsValid(ply) then return end
    local replacement = self:GetReplacement()
    if replacement then
        ply:SetModel(replacement)
    end
end

function ITEM:OnUnequipped()
    local ply = self.player
    if not IsValid(ply) then return end
    ply:SetModel(ply:GetCharacter():GetModel()) -- restore original
end
