ITEM.name = "Bleach"
ITEM.model = Model("models/illusion/eftcontainers/bleach.mdl")
ITEM.description = "Bleach could be used on your clothes, but it could also be used on someone you dislike. Most people use the former."
ITEM.category = "Junk"
ITEM.width = 1
ITEM.height = 2

ITEM.functions.Drink = {
	sound = "npc/barnacle/barnacle_gulp1.wav",
	OnRun = function(itemTable)
		local client = itemTable.player

		PrintMessage(HUD_PRINTTALK, "Oh fuck.")
		
		return true
	end,
}