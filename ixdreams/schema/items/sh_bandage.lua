ITEM.base = "base_consumable"

ITEM.name = "Bandages"
ITEM.model = Model("models/stuff/bandages_dirty.mdl")
ITEM.description = "A small roll of hand-made gauze."
ITEM.category = "Medical"
ITEM.uses = 5

ITEM.functions.Use = {
	Name = "Use",
	OnRun = function(item)
		local bShouldRemoveItem = false
		local client = item.player
		local character = client:GetCharacter()
		
		client:ChatPrint("You tear off a strip of bandages and patch your wounds.")
		client:EmitSound("physics/plaster/ceilingtile_break1.wav", 75, 150, 0.5)

		character:AddStatusEffect("med_bandage", 100)
		
		bShouldRemoveItem = item:ConsumeUse()
		
		return bShouldRemoveItem
	end,
	OnCanRun = function(item)
		local client = item.player
		local health = client:Health()
		local maxHealth = client:GetMaxHealth()
		
		return health < maxHealth
	end
}

ITEM.functions.UseAll = nil

ITEM.functions.Give = {
	Name = "Give",
	OnRun = function(item)
		local bShouldRemoveItem = false
		local client = item.player
		local character = client:GetCharacter()
		
		local trace = client:GetEyeTrace()  -- Perform a trace from the player's eye position
        local target = trace.Entity
		local targetCharacter = (IsValid(target) and target:IsPlayer()) and target:GetCharacter()
		local sChatName = (hook.Run("IsCharacterRecognized", character, targetCharacter:GetID()) and targetCharacter:GetName()) or "Someone"
		
		client:ChatPrint("You tear off a strip of bandages.")
		target:ChatPrint(sChatName .. " patches your wounds.")
		client:EmitSound("physics/plaster/ceilingtile_break1.wav", 75, 150, 0.5)
		
		targetCharacter:AddStatusEffect("med_bandage", 100)
		
		bShouldRemoveItem = item:ConsumeUse()
		
		return bShouldRemoveItem
	end,
	OnCanRun = function(item)
		local client = item.player
		local trace = client:GetEyeTrace()  -- Perform a trace from the player's eye position
		local target = trace.Entity

		return IsValid(target) and target:IsPlayer()
	end
}

