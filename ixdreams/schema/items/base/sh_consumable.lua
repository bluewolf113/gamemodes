-- ITEM.base = "base_0xbase"

ITEM.name = "Consumable Base"
ITEM.model = Model("models/willardnetworks/food/prop_bar_bottle_e.mdl")
ITEM.description = "A base with multiple uses."
ITEM.messages = {delay = 12, ["Use"] = "You use the item."}
ITEM.category = "Consumable"
ITEM.width = 1
ITEM.height = 1
ITEM.uses = 1
ITEM.sounds = {}
ITEM.bDeleteOnConsumption = true

function ITEM:GetNeeds()
	local needs = self.needs
	return needs
end

function ITEM:GetStatusEffects()
	local statusEffects = self.statusEffects
	return statusEffects
end

function ITEM:GetMessages()
	local messages = self.messages
	return messages
end

function ITEM:GetSounds()
	return self.sounds
end

function ITEM:GetJunkItems()
	return self.junk
end

-- function ITEM:OverrideNeed(uniqueID, newValue)
	-- self:SetData(uniqueID .. "ValueOverride", newValue)
-- end

-- function ITEM:OverrideStatusEffect(uniqueID, newValue)
	-- self:SetData(uniqueID .. "ValueOverride", newValue)
-- end

-- function ITEM:OverrideMessage(uniqueID, newValue)
	-- self:SetData(uniqueID .. "MessageOverride")
-- end

-- function ITEM:OverrideSound(uniqueID, newValue)
	-- self:SetData(uniqueID .. "MessageOverride")
-- end

ITEM.functions.Use = {
	name = ITEM.useText or "Use",
	icon = "icon16/cog.png",
	OnRun = function(item)
		local client = item.player
		
		if not client then print("functions.Use: not client") return end
		
		local character = client:GetCharacter()
		
		if not character then print("functions.Use: not character") return end
		
		local bShouldRemoveItem = false
		
		local tblNeeds = item:GetNeeds() 			or {}
		local tblStats = item:GetStatusEffects() 	or {}
		local tblMsgs = item:GetMessages() 			or {}
		local tblSounds = item:GetSounds() 			or {}
		local tblJunk = item:GetJunkItems() 		or {}
		
		local message = tblMsgs[item.useText] or "No message set for function " .. item.useText 
		local bNoMessage = item:GetData("noMessage", nil)
		
		local sound = (istable(tblSounds[item.useText]) and tblSounds[item.useText][math.random(#(tblSounds))])or tblSounds[item.useText] or tblSounds[math.random(#(tblSounds))]	
		
		if not bNoMessage then
			client:ChatPrint(message)
			item:SetData("noMessage", true)
			timer.Simple(tblMsgs.delay or 12, function() item:SetData("noMessage", false) end)
		end
		
		local tblSoundParams = (istable(sound) and sound) or {sound, 75, 70, 1.0}
		
		client:EmitSound(unpack(tblSoundParams))
		
		for k, v in pairs(tblNeeds) do
			character:AddNeed(k, v)
		end
		
		for k, v in pairs(tblStats) do
			character:AddStatusEffect(k, v)
		end
		
		bShouldRemoveItem = item:ConsumeUse() and item.bDeleteOnConsumption
		
		if bShouldRemoveItem and tblJunk then
			item:SpawnJunkItems()
		end
		
		return bShouldRemoveItem
	end,
	
	OnCanRun = function(item)
		local currUses = item:GetData("uses", 1)
		return currUses > 0
	end
}

ITEM.functions.UseAll = {
	name = (ITEM.useText or "Use") .. " All",
	icon = "icon16/cog_add.png",
	OnRun = function(item)
		local client = item.player
		
		if not client then return end
		
		local character = client:GetCharacter()
		
		if not character then return end
		
		local bShouldRemoveItem = item.bDeleteOnConsumption
		
		local tblNeeds = item:GetNeeds()			or {}
		local tblStats = item:GetStatusEffects()	or {}
		local tblMsgs = item:GetMessages()			or {}
		local tblSounds = item:GetSounds()			or {}
		local tblJunk = item:GetJunkItems()			or {}
		
		local message = tblMsgs[item.useText] or "No message set for function " .. item.useText 
		local bNoMessage = item:GetData("noMessage", nil)
		
		local sound = (istable(tblSounds[item.useText]) and tblSounds[item.useText][math.random(#(tblSounds))])or tblSounds[item.useText] or tblSounds[math.random(#(tblSounds))]	
		
		local currUses = item:GetData("uses", 1)
		
		if not bNoMessage then
			client:ChatPrint(message)
			item:SetData("noMessage", true)
			timer.Simple(tblMsgs.delay, function() item:SetData("noMessage", false) end)
		end
		
		local tblSoundParams = (istable(sound) and sound) or {sound, 75, 70, 1.0}
		
		client:EmitSound(unpack(tblSoundParams))
		
		for k, v in pairs(tblNeeds) do
			character:AddNeed(k, v * currUses)
		end
		
		for k, v in pairs(tblStats) do
			character:AddStatusEffect(k, v * currUses)
		end
		
		item:ConsumeAllUses()
		
		if bShouldRemoveItem and tblJunk then
			print("Use: attempting junk spawn")
			item:SpawnJunkItems()
		end
		
		return bShouldRemoveItem
	
	end, 
	
	OnCanRun = function(item)
		local currUses = item:GetData("uses", 1)			
		return currUses > 1
	end
}

ITEM:Hook("OnRegistered", "SetupConsumableFunctions", function(item, data)
	if (item.functions.Use and item.functions.UseAll) and not item.isBase then
		item.needs = (item.GetNeeds and item:GetNeeds()) or item.needs or {}
		item.statusEffects = (item.GetStatusEffects and item:GetStatusEffects()) or item.statusEffects or {}
		item.messages = (item.GetMessages and item:GetMessages()) or item.messages or {}

		item.functions.Use.name = item.useText or "Use"
		item.functions.Use.icon = item.useIcon or "icon16/cog.png"

		item.functions.UseAll.name = item.useAllText or (item.useText and item.useText .. " All") or "Use All"
		item.functions.UseAll.icon = item.useAllIcon or item.useIcon or "icon16/cog_add.png"
	end	
end)

ITEM:Hook("OnInstanced", "InitializeConsumableUses", function(invID, x, y, item, data)
	if item.uses then
		local uniqueID = "uses"
		local v = (istable(item.uses) and not istable(item.uses["init"]) and item.uses["init"]) or (istable(item.uses) and istable(item.uses["init"]) and #item.uses["init"] == 2 and math.random(item.uses["init"][1], item.uses["init"][2])) or item.uses
		item:SetData(uniqueID, v)
	end
end)

-- -- Called after the item is registered into the item tables.
-- function ITEM:OnRegistered()
	-- local useText = self.useText or "Use"
	-- local useAllText = self.useAllText or useText .. " All"
	-- local useIcon = self.useIcon or "icon16/cog.png"
	-- local useAllIcon = self.useAllIcon or useIcon
	
	-- self.functions.Use.name = useText
	-- self.functions.Use.icon = useIcon

	-- self.functions.UseAll.name = useAllText
	-- self.functions.UseAll.icon = useAllIcon
-- end

function ITEM:SetUses(identifier, num)
	local value
	local uniqueID
	
	if not identifier then
		if self.uses and istable(self.uses) then
			for k, v in pairs(self.uses) do
				value = num or v
				uniqueID = "uses_".. string.lower(k)
				self:SetData(uniqueID, v)
				break
			end
		else
			uniqueID = "uses"
			self:SetData(uniqueID, v)
		end
		
	elseif identifier then
		value = num or self:GetData(uniqueID, nil)
		local uniqueID = "uses_".. string.lower(identifier)
		self:SetData(uniqueID, value)
	end
end

function ITEM:GetUses(identifier)
	local usesValue
	
	if not identifier then
		if istable(self.uses) then
			for k, v in pairs(self.uses) do
				local uniqueID = "uses_".. string.lower(k)
				usesValue = self:GetData(uniqueID, nil)
				break
			end
		else
			local uniqueID = "uses"
			usesValue = self:GetData(uniqueID, nil)
		end
		
	elseif identifier then
		local uniqueID = "uses_".. string.lower(identifier)
		usesValue = self:GetData(uniqueID, nil)
	end
	
	return usesValue
end

function ITEM:ConsumeUse(identifier, num)			
	local uniqueID = "uses"
	local numUses = num or 1
	
	useData = self:GetData(uniqueID, nil)
	
	if useData then
	
		self:SetData(uniqueID, math.Clamp(useData - numUses, 0, useData))	
		useData = self:GetData(uniqueID, 0)
		
		return useData <= 0
	else
		return true
	end
end

function ITEM:ConsumeAllUses(identifier)
	local uniqueID = "uses"
		
	local num = self:GetData(uniqueID, nil)
		
	if num then 
		return self:ConsumeUse(identifier, self:GetData(uniqueID, num))
	else
		return true
	end
	
end

function ITEM:SpawnJunkItems()
	local ply = self:GetOwner()
	local junkItems = self.junk	
	
	if not ply or not junkItems then return end
	
	if ply then	
		print("SpawnJunkItems: creating timer")
		timer.Simple(0.1, function() Schema:SpawnItemsOnPlayer(ply, junkItems) end)
	end
end

if CLIENT then
	do
		local itemMeta = ix.meta.item
		-- Display uses on item tooltip
		function itemMeta:PopulateTooltip(tooltip)	
			local uses = self.uses
			local usesAlias = self.usesAlias or "Uses"
			local currUses = self:GetData("uses", nil)
			local bNoDisplay = self.bNoDisplay
		
			if uses and currUses and not self.bNoDisplay then
				local usesRow = tooltip:AddRow("uses")
				usesRow:SetText((self.GetUsesTooltip and self:GetUsesTooltip()) or (self.usesAlias or "Uses") .. " left: " .. tostring(currUses))
				usesRow:SizeToContents()
			end
			
		end
	end
end