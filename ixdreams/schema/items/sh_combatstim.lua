ITEM.base = "base_consumable"

ITEM.name = "Combat Stim"
ITEM.model = Model("models/willardnetworks/skills/syringeammo.mdl")
ITEM.description = "A cocktail of experimental drugs."
ITEM.messages = {["Inject"] = "Your heart pumps fast as ever. You feel wired, yet in perfect control."}
ITEM.category = "Drugs"
ITEM.uses = 1
ITEM.junk = {["emptysyringe1"] =  1}
ITEM.sounds = {["Inject"] = "player/suit_sprint.wav"}
ITEM.itx_combatStim = 80
ITEM.bNoDisplay = true
ITEM.useText = "Inject"
ITEM.useIcon = "icon16/pill.png"

function ITEM:GetStatusEffects()
	local statsTbl = {}
	
	statsTbl["itx_combatstim"] = self.itx_combatStim
	
	return statsTbl
end