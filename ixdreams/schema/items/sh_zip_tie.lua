ITEM.name = "Zip Cuffs"
ITEM.description = "A plastic physical restraint. They work like metal cuffs, but are easier to carry and far more cheap."
ITEM.model = "models/freeman/flexcuffs.mdl"
ITEM.factions = {FACTION_MPF, FACTION_OTA}
ITEM.category = "Miscellaneous"
ITEM.functions.Use = {
	OnRun = function(itemTable)
		local client = itemTable.player
		local character = client:GetCharacter()
		
		local data = {}
			data.start = client:GetShootPos()
			data.endpos = data.start + client:GetAimVector() * 96
			data.filter = client
		local target = util.TraceLine(data).Entity
		
		local attr = "dex"
		
		local plyDex = character:GetAttribute(attr, 0)
		local maxDex = ix.attributes.list[attr].maxValue or 100
		local actionTime = math.Clamp(10 - (10 * (plyDex / maxDex)), 2, 10)

		if (IsValid(target) and target:IsPlayer() and target:GetCharacter()
		and !target:GetNetVar("tying") and !target:IsRestricted()) then
			itemTable.bBeingUsed = true

			client:SetAction("@tying", actionTime)

			client:DoStaredAction(target, function()
				target:SetRestricted(true)
				target:SetNetVar("tying")
				target:NotifyLocalized("fTiedUp")

				itemTable:Remove()
			end, actionTime, function()
				client:SetAction()

				target:SetAction()
				target:SetNetVar("tying")

				itemTable.bBeingUsed = false
			end)

			target:SetNetVar("tying", true)
			target:SetAction("@fBeingTied", actionTime)
		else
			itemTable.player:NotifyLocalized("plyNotValid")
		end

		return false
	end,
	OnCanRun = function(itemTable)
		local client = itemTable.player
		local character = client:GetCharacter()
		
		return (!IsValid(itemTable.entity) or itemTable.bBeingUsed) and character:GetAttribute("dex", 0) >= 0
	end
}

function ITEM:CanTransfer(inventory, newInventory)
	return !self.bBeingUsed
end
