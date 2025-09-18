ITEM.name = "Paper Bag"
ITEM.description = "For holding items or for covering up your dirt-ass mug."
ITEM.category = "Clothing"
ITEM.model = "models/props_lab/box01a.mdl"
ITEM.skin = 13
ITEM.width = 2
ITEM.height = 2
ITEM.outfitCategory = "hat"
ITEM.pacData = {[1] = {
    ["children"] = {
        [1] = {
            ["children"] = {
            },
            ["self"] = {
                ["Skin"] = 13,
                ["Invert"] = false,
                ["LightBlend"] = 1,
                ["CellShade"] = 0,
                ["OwnerName"] = "self",
                ["AimPartName"] = "",
                ["IgnoreZ"] = false,
                ["AimPartUID"] = "",
                ["Passes"] = 1,
                ["Name"] = "",
                ["NoTextureFiltering"] = false,
                ["DoubleFace"] = false,
                ["PositionOffset"] = Vector(0, 0, 0),
                ["IsDisturbing"] = false,
                ["Fullbright"] = false,
                ["EyeAngles"] = false,
                ["DrawOrder"] = 0,
                ["TintColor"] = Vector(0, 0, 0),
                ["UniqueID"] = "1868347450",
                ["Translucent"] = false,
                ["LodOverride"] = -1,
                ["BlurSpacing"] = 0,
                ["Alpha"] = 1,
                ["Material"] = "",
                ["UseWeaponColor"] = false,
                ["UsePlayerColor"] = false,
                ["UseLegacyScale"] = false,
                ["Bone"] = "eyes",
                ["Color"] = Vector(255, 255, 255),
                ["Brightness"] = 1,
                ["BoneMerge"] = false,
                ["BlurLength"] = 0,
                ["Position"] = Vector(-3.527, -0.15, -1.935),
                ["AngleOffset"] = Angle(0, 0, 0),
                ["AlternativeScaling"] = false,
                ["Hide"] = false,
                ["OwnerEntity"] = false,
                ["Scale"] = Vector(1, 1, 1),
                ["ClassName"] = "model",
                ["EditorExpand"] = false,
                ["Size"] = 1,
                ["ModelFallback"] = "",
                ["Angles"] = Angle(0, 0, 0),
                ["TextureFilter"] = 3,
                ["Model"] = "models/props_junk/watermelon01.mdl",
                ["BlendMode"] = "",
            },
        },
    },
    ["self"] = {
        ["DrawOrder"] = 0,
        ["UniqueID"] = "197916561",
        ["AimPartUID"] = "",
        ["Hide"] = false,
        ["Duplicate"] = false,
        ["ClassName"] = "group",
        ["OwnerName"] = "self",
        ["IsDisturbing"] = false,
        ["Name"] = "my outfit",
        ["EditorExpand"] = true,
    },
},
}

if (CLIENT) then
	-- Draw camo if it is available.
	function ITEM:PaintOver(item, w, h)
		if (item:GetData("equip")) then
			surface.SetDrawColor(110, 255, 110, 100)
			surface.DrawRect(w - 14, h - 14, 8, 8)
		end
	end
end

function ITEM:RemovePart(client)
	local char = client:GetCharacter()

	self:SetData("equip", false)
	client:RemovePart(self.uniqueID)

	if (self.attribBoosts) then
		for k, _ in pairs(self.attribBoosts) do
			char:RemoveBoost(self.uniqueID, k)
		end
	end

	self:OnUnequipped()
end

-- On item is dropped, Remove a weapon from the player and keep the ammo in the item.
ITEM:Hook("drop", function(item)
	if (item:GetData("equip")) then
		item:RemovePart(item.player)
	end
end)

-- On player uneqipped the item, Removes a weapon from the player and keep the ammo in the item.
ITEM.functions.EquipUn = { -- sorry, for name order.
	name = "Unequip",
	tip = "equipTip",
	icon = "icon16/cross.png",
	OnRun = function(item)
		item:RemovePart(item.player)

		return false
	end,
	OnCanRun = function(item)
		local client = item.player

		return !IsValid(item.entity) and IsValid(client) and item:GetData("equip") == true and
			hook.Run("CanPlayerUnequipItem", client, item) != false and item.invID == client:GetCharacter():GetInventory():GetID()
	end
}

-- On player eqipped the item, Gives a weapon to player and load the ammo data from the item.
ITEM.functions.Equip = {
	name = "Equip",
	tip = "equipTip",
	icon = "icon16/tick.png",
	OnRun = function(item)
		local char = item.player:GetCharacter()
		local items = char:GetInventory():GetItems()

		for _, v in pairs(items) do
			if (v.id != item.id) then
				local itemTable = ix.item.instances[v.id]

				if (itemTable.pacData and v.outfitCategory == item.outfitCategory and itemTable:GetData("equip")) then
					item.player:Notify("You're already equipping this kind of outfit")

					return false
				end
			end
		end

		item:SetData("equip", true)
		item.player:AddPart(item.uniqueID, item)

		if (item.attribBoosts) then
			for k, v in pairs(item.attribBoosts) do
				char:AddBoost(item.uniqueID, k, v)
			end
		end

		item:OnEquipped()
		return false
	end,
	OnCanRun = function(item)
		local client = item.player

		return !IsValid(item.entity) and IsValid(client) and item:GetData("equip") != true and
			hook.Run("CanPlayerEquipItem", client, item) != false and item.invID == client:GetCharacter():GetInventory():GetID()
	end
}

function ITEM:CanTransfer(oldInventory, newInventory)
	if (newInventory and self:GetData("equip")) then
		return false
	end

	return true
end

function ITEM:OnRemoved()
	local inventory = ix.item.inventories[self.invID]
	local owner = inventory.GetOwner and inventory:GetOwner()

	if (IsValid(owner) and owner:IsPlayer()) then
		if (self:GetData("equip")) then
			self:RemovePart(owner)
		end
	end
end

function ITEM:OnEquipped()
end

function ITEM:OnUnequipped()
end