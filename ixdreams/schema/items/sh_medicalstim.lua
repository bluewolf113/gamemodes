ITEM.base = "base_consumable"

ITEM.name = "Medical Stim"
ITEM.model = Model("models/willardnetworks/syringefull.mdl")
ITEM.description = "A Combine dermal healing shot."
ITEM.category = "Medical"
ITEM.uses = 1
ITEM.junk = {["emptysyringe2"] =  1}
ITEM.bNoDisplay = true

ITEM.functions.Use = {
	name = "Use",
	icon = "icon16/pill.png",
	OnRun = function(item)
		local bShouldRemoveItem = true
		local client = item.player
		local character = client:GetCharacter()	
		
		client:EmitSound("hl1/fvox/boop.wav", 75, 90, 0.35)
		
		timer.Simple(0.5, function() 	
		client:ChatPrint("There's a pinch--Then you feel good as new.")
		client:EmitSound("hl1/fvox/hiss.wav", 75, 90, 0.35)
		character:AddStatusEffect("med_healgel", 100)
		item:SpawnJunkItems()
			end)
		
		
		
		return bShouldRemoveItem
	end,
}

ITEM.functions.Give = {
	Name = "Give",
	OnRun = function(item)
		local bShouldRemoveItem = true
		local client = item.player
		local character = client:GetCharacter()
		
		local trace = client:GetEyeTrace()  -- Perform a trace from the player's eye position
        local target = trace.Entity
		local targetCharacter = (IsValid(target) and target:IsPlayer()) and target:GetCharacter()
		local sChatName = (hook.Run("IsCharacterRecognized", character, targetCharacter:GetID()) and targetCharacter:GetName()) or "Someone"
		
		target:EmitSound("hl1/fvox/boop.wav", 75, 90, 0.35)
		
		timer.Simple(0.5, function() 	
		target:ChatPrint("There's a pinch--Then you feel good as new.")
		target:EmitSound("hl1/fvox/hiss.wav", 75, 90, 0.35)
		targetCharacter:AddStatusEffect("med_healgel", 100)
		item:SpawnJunkItems()
			end)
		
		return bShouldRemoveItem
	end,
	OnCanRun = function(item)
		local client = item.player
		local trace = client:GetEyeTrace()  -- Perform a trace from the player's eye position
		local target = trace.Entity

		return IsValid(target) and target:IsPlayer()
	end
}
