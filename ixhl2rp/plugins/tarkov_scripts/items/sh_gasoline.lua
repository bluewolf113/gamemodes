ITEM.name = "Metal Gas Can"
ITEM.model = Model("models/illusion/eftcontainers/gasoline.mdl")
ITEM.description = "A heavy metal tank full of varying petrols and fuels, making it highly flammable but also invaluable to certain individuals whether it's for satisfying power needs or creating a deadly inferno."
ITEM.category = "Junk"
ITEM.width = 2
ITEM.height = 2

ITEM.functions.Huff = {
	OnRun = function(itemTable)
		local client = itemTable.player

		client:GetCharacter():AddBoost("buff1", "stm", 3)

		hook.Run("SetupDrugTimer", client, client:GetCharacter(), itemTable.uniqueID, 10)
		
		return false
	end
}

ITEM.screenspaceEffects = function()
	DrawMotionBlur(0.15, 1, 0)
end

ITEM.functions.Drink = {
	sound = "npc/barnacle/barnacle_gulp1.wav",
	OnRun = function(itemTable)
		local client = itemTable.player
		
		timer.Create( "UniqueName1", 1, 5, function() client:SetHealth(math.min(client:Health() - 10, 100)) end ) 

		return true
	end,
}