ITEM.name = "Junk"
ITEM.model = Model("models/willardnetworks/food/prop_bar_bottle_e.mdl")
ITEM.description = "A base for junk items."
ITEM.salvageDescription = "You dismantle the thing."
ITEM.category = "Junk"
ITEM.width = 1
ITEM.height = 1
ITEM.sounds = {"physics/metal/metal_solid_impact_hard1.wav"}

ITEM.functions.Salvage = {
	name = "Salvage",
	icon = "icon16/box.png",
	OnRun = function(item)
		local bShouldRemoveItem = true
		local client = item.player
		local character = client:GetCharacter()
		
		client:ChatPrint(item.salvageDescription)
		client:EmitSound(item.sounds[math.random(#(item.sounds))], 75, 100, 0.35)
		
		item:SpawnScrapItems()
		
		return bShouldRemoveItem
	end,
	OnCanRun = function(item)
		local bHasScrap = false
		
		for k, v in pairs(item.scrap or {}) do
			if k or v then 
				bHasScrap = true
				break
			end
		end
		
		return bHasScrap
	end
}

function ITEM:SpawnScrapItems()
	local client = self.player
	if not client then return end
	
	local scrapItems = table.Copy(self.scrap)
	
	if scrapItems then
		timer.Simple(0.1, function() Schema:SpawnItemsOnPlayer(client, scrapItems) end)
	end
end