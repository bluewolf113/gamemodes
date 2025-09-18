ITEM.name = "Militant Uniform"
ITEM.description = "An outfit fully-equipped with kevlar-plating, a repurposed CPF-undershirt, padded denims and a pair of steel-toed boots. Additionally, a satchel is included for easy storage of vital utilities."
ITEM.model = "models/willardnetworks/update_items/armor01_item.mdl"
ITEM.skin = 0
ITEM.noResetBodyGroups = true
ITEM.height = 1
ITEM.width = 1
ITEM.category = "Clothing Sets"
ITEM.outfitCategory = "Outfit"

ITEM.bodyGroups = {
	["Torso"] = 38,
	["Legs"] = 8,
	["Hands"] = 1,
	["Satchel"] = 1,
	["Shoes"] = 6
}

local defaultArmor = 50

ITEM:PostHook("Equip", function(item)
    local armor = item:GetData("armor")
    if not armor then
        item.player:SetArmor(defaultArmor)
        item:SetData("armor", defaultArmor)
    else
        item.player:SetArmor(math.min(armor, defaultArmor))
    end
end)

ITEM:PostHook("EquipUn", function(item)
    item:SetData(item.player:Armor())
    item.player:SetArmor(0)
end)

ITEM:PostHook("drop", function(item)
    item:SetData(item.player:Armor())
    item.player:SetArmor(0)
end)

function ITEM:OnEquipped()
    self.player:EmitSound( "stalkersound/inv_disassemble_cloth_fast_2.ogg", 100, 50, 0.30)
end