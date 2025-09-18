ITEM.base = "base_consumable"

ITEM.name = "Dispenser Base"
ITEM.model = Model("models/props_lab/box01a.mdl")
ITEM.description = "A base for items that dispense other items."
ITEM.category = "Miscellaneous"
ITEM.uses = 3
ITEM.sounds = {"physics/body/body_medium_impact_soft5.wav"}
ITEM.useText = "Dispense"
ITEM.dispenseItem = "scrapmetal"

-- function ITEM:CanDispense(client)
	-- local client = client or item.player

	-- return IsValid(client)
-- end

ITEM:PostHook("Use", function(item)
	local client = item:GetOwner() or item.player
	local character = client:GetCharacter()
	
	local bCanDispense = character and item.CanDispense and item:CanDispense(client) or true
	
	if (bCanDispense) then
		Schema:SpawnItemsOnPlayer(client, item.dispenseItem or {})
	end
end)