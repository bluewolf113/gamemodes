ITEM.base = "base_consumable"

ITEM.name = "Bandages"
ITEM.model = Model("models/stuff/bandages_dirty.mdl")
ITEM.description = "A small roll of hand-made gauze."
ITEM.category = "Medical"
ITEM.uses = 5

function ITEM:PopulateTooltip(tooltip)
    local uses = self:GetData("uses", self.uses or 0)

    local row = tooltip:AddRowAfter("description", "uses")
    row:SetText("Uses left: " .. uses)
    row:SizeToContents()
end

ITEM.functions.Use = {
	Name = "Use",
	OnRun = function(item)
		local bShouldRemoveItem = false
		local client = item.player
		local character = client:GetCharacter()
		
		client:ChatPrint("You tear off a strip of bandages and patch your wounds.")
		client:EmitSound("physics/plaster/ceilingtile_break1.wav", 75, 150, 0.5)

		character:AddStatusEffect("med_bandage", 100)
        character:RemoveStatusEffect("bleeding")
        character:RemoveStatusEffect("bleedingheavy")
		
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

ITEM.functions.combine = {
    OnRun = function(item, data)
        local client = item.player
        local container = ix.item.instances[data and data[1]]
        if not (IsValid(client) and container) then return false end

        local char = client:GetCharacter()
        local inv = char and char:GetInventory()
        if not inv then return false end

        local liquid = container:GetData("currentLiquid", nil)
        local volume = container:GetData("currentAmount", 0)

        if liquid ~= "rubbingalc" then
            client:Notify("This container doesn't hold alcohol.")
            return false
        end

        if volume < 50 then
            client:Notify("Not enough alcohol to sterilize the bandage.")
            return false
        end

        local movementKeys = {
            [KEY_W] = true,
            [KEY_A] = true,
            [KEY_S] = true,
            [KEY_D] = true,
            [KEY_SPACE] = true,
            [KEY_LSHIFT] = true
        }

        local cancelHook = "ixSterilizeCancel_" .. client:SteamID()
        local canceled = false

        hook.Add("PlayerButtonDown", cancelHook, function(ply, button)
            if ply == client and movementKeys[button] then
                canceled = true
                client:SetAction()
                hook.Remove("PlayerButtonDown", cancelHook)
            end
        end)

        client:SetAction("Sterilizing bandage...", 1.9, function()
            hook.Remove("PlayerButtonDown", cancelHook)
            if canceled then return end

            container:SetData("currentAmount", volume - 50)

            inv:Add("sterilizedbandage", 1, nil, item.x, item.y)
            item:Remove()

            client:EmitSound("ambient/water/water_spray2.wav", 75, 150, 0.5)
        end)

        return false
    end,

    OnCanRun = function(item, data)
        local container = ix.item.instances[data and data[1]]
        if not container then return false end

        local liquid = container:GetData("currentLiquid", nil)
        local volume = container:GetData("currentAmount", 0)
    end
}