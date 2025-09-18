ITEM.name = "Shock Roach"
ITEM.description = "A symbiotic alien resembling a large insect--with mandibles that shock."
ITEM.model = "models/weapons/opfor/w_shock.mdl"
ITEM.class = "weapon_shockrifle"
ITEM.weaponCategory = "primary"
ITEM.flag = ""
ITEM.width = 2
ITEM.height = 1

ITEM:PostHook("Equip", function(item)
	if (item:GetData("equip")) then
		local character = ix.char.loaded[item.owner]
		local client = character and character:GetPlayer() or item:GetOwner()

		if (client) then
			client:ChatPrint("The roach clings to you, boring pincers into the flesh of your arm.")
			client:SetHealth(client:Health() - 5)
			client:EmitSound("npc/headcrab/headbite.wav", 75, 35)
		end
	end
end)

ITEM:PostHook("EquipUn", function(item)
	local character = ix.char.loaded[item.owner]
	local client = character and character:GetPlayer() or item:GetOwner()

	if (client) then
		client:ChatPrint("You tear away the roach, leaving pincers embedded in the flesh of your arm.")
		client:SetHealth(client:Health() - 20)
		client:EmitSound("physics/body/body_medium_break4.wav")
	end
end)