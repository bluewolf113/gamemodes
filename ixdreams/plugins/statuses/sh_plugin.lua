local PLUGIN = PLUGIN

PLUGIN.name = "Statuses"
PLUGIN.author = "kingbolt"
PLUGIN.description = "Add status effects to characters."

PLUGIN.statuses = PLUGIN.statuses or {}
PLUGIN.activeChars = PLUGIN.activeChars or {}

function PLUGIN:RegisterStatusEffect(STATUS)
    if STATUS and STATUS.name then
		local uniqueID = STATUS.uniqueID
        PLUGIN.statuses[uniqueID] = STATUS
    end
end

ix.char.RegisterVar("statuses", {
		default = {},
		isLocal = true,
		OnSet = function(self, character, uniqueID, scale)
			local statuses = character.vars.statuses or {}
			local status = PLUGIN:GetStatusTable(uniqueID)
			local scaleMin = status.scaleMin or 0
			local client = character:GetPlayer()
			
			net.Start("ixCharacterStatusChanged")
				net.WriteUInt(character:GetID(), 32)
				net.WriteString(uniqueID)
				net.WriteFloat(scale)
			net.Send(client)
		
			if scale < scaleMin then
				statuses[uniqueID] = nil
			else
				statuses[uniqueID] = scale
			end

			character.vars.statuses = statuses
		end,
		OnGet = function(self, character, uniqueID)
			local data = character.vars.statuses or {}	
			
			if uniqueID then
				return data[uniqueID]
			else
				return data
			end
		end
	})
	
function PLUGIN:GetActiveCharacters()
	return PLUGIN.activeChars
end

function PLUGIN:AddActiveCharacter(character)
	if character then
		PLUGIN.activeChars[character:GetID()] = character
	end
end

-- Function to remove a player from the active players table if they have no active status effects

function PLUGIN:RemoveActiveCharacter(character, bNoCheck)
	if character then
		local bNoRemove = false
		local storedCharacter = PLUGIN.activeChars[character:GetID()]
		if character == storedCharacter then	
			if bNoCheck then
				PLUGIN.activeChars[character:GetID()] = nil
			else
				local statusEffects = character:GetStatuses(character)			
				for uniqueID, charStatus in pairs(statusEffects) do
					if charStatus then 
						bNoRemove = true 
						break
					end
				end
				
				if not bNoRemove then
					PLUGIN.activeChars[character:GetID()] = nil
				end
			end	
		end
	end
end

function PLUGIN:StatusExists(uniqueID)
	if PLUGIN.statuses[uniqueID] then
		return true
	else
		return false
	end
end

function PLUGIN:GetStatusesTable()
	return PLUGIN.statuses
end

function PLUGIN:GetStatusTable(uniqueID)
	if not PLUGIN.statuses[uniqueID] then
		for _, status in pairs(PLUGIN.statuses) do	
			if not status or not status.uniqueID then return end
			
			if status.uniqueID == uniqueID or string.find(status.uniqueID, uniqueID) or status.name == uniqueID or string.find(status.name, uniqueID) then
				return status
			end
		end
	else	
		return PLUGIN.statuses[uniqueID]
	end
end

do
	local charMeta = ix.meta.character
	
	function charMeta:GetStatusEffect(uniqueID)
		if self then
			return self:GetStatuses(self, uniqueID)
		end
	end

	function charMeta:SetStatusEffect(uniqueID, scale, bNoApply)
		if self then
			local client = self:GetPlayer()
			local status = PLUGIN:GetStatusTable(uniqueID)
			local scaleMin = status.scaleMin or 0
			local charStatus = self:GetStatusEffect(uniqueID)
			
			PLUGIN:AddActiveCharacter(self)
			self:SetStatuses(self, uniqueID, scale)
			
			if not bNoApply then
				status:OnApply(client)
			end
		end
	end

	function charMeta:AddStatusEffect(uniqueID, scale)
		if self then
			local status = PLUGIN:GetStatusTable(uniqueID)
			local charStatus = self:GetStatusEffect(uniqueID)
			local scaleMin = status.scaleMin or 0
			local scaleMax = status.scaleMax or 100
			local bNoApplyEffect = (charStatus and charStatus > scaleMin)
			
			if bNoApplyEffect then
				local newScale = math.Clamp(charStatus + (scale or scaleMax), scaleMin, scaleMax)
				self:SetStatusEffect(uniqueID, newScale, bNoApplyEffect)
			else	
				self:SetStatusEffect(uniqueID, scale)
			end
		end
	end

	function charMeta:RemoveStatusEffect(uniqueID, scale)
		if self then
			local client = self:GetPlayer()

			local status = PLUGIN:GetStatusTable(uniqueID)
			local scaleMin = status.scaleMin or 0
			
			self:SetStatusEffect(uniqueID, scaleMin - 1, true)
			PLUGIN:RemoveActiveCharacter(self)
			status:OnRemove(client)
		end
	end
end

ix.util.Include("sv_hooks.lua")
ix.util.Include("cl_hooks.lua")

-- ---------------------------
-- Include status effects here

ix.util.Include("statuses/sh_drunk.lua")
ix.util.Include("statuses/sh_itx_combatstim.lua")
ix.util.Include("statuses/sh_itx_synthoil.lua")
ix.util.Include("statuses/sh_med_healgel.lua")
ix.util.Include("statuses/sh_med_bandage.lua")

-- ---------------------------

ix.command.Add("PlySetStatus", {
	description = "Apply a status effect to the target.",
	adminOnly = true,
	arguments = {ix.type.player, ix.type.string, ix.type.number, optional = true},
	OnRun = function(self, client, target, uniqueID, scale)
		local character = client:GetCharacter()
		if not character then return end
		
		local statTbl = PLUGIN:GetStatusTable(uniqueID)
		
		if statTbl then
			local scale = scale or statTbl.scaleMax
			local sDisplayName = statTbl.name
			character:SetStatusEffect(statTbl.uniqueID, scale)
			client:ChatPrint("Status effect '" .. sDisplayName .. "' set to " .. (scale) .. "% on the target.")
		else
			client:ChatPrint("Invalid status effect.")
		end
	end
})

ix.command.Add("PlyModStatus", {
	description = "Modify the magnitude of a status effect on the target.",
	adminOnly = true,
	arguments = {ix.type.player, ix.type.string, ix.type.number, optional = true},
	OnRun = function(self, client, target, uniqueID, scale)
		local character = client:GetCharacter()
		if not character then return end

		local statTbl = PLUGIN:GetStatusTable(uniqueID)

		if statTbl then
			local scale = scale or statTbl.scaleMax
			local sDisplayName = statTbl.name
			character:AddStatusEffect(statTbl.uniqueID, scale)
			client:ChatPrint("Status '" .. sDisplayName .. "' set to " .. (scale) .. "% on target.")
		else
			client:ChatPrint("Invalid status effect.")
		end
	end
})

ix.command.Add("PlyRemoveStatus", {
	description = "Remove a status effect from the target.",
	adminOnly = true,
	arguments = {ix.type.player, ix.type.string},
	OnRun = function(self, client, target, uniqueID)
		local statTbl = PLUGIN:GetStatusTable(uniqueID)
		local character = target:GetCharacter()
		uniqueID = statTbl.uniqueID or uniqueID
		
		if not character then return end
		
		local charStatus = character:GetStatusEffect(uniqueID)
				
		if statTbl and charStatus then
			local character = target:GetCharacter()
			local sDisplayName = statTbl.name
			character:RemoveStatusEffect(uniqueID)
			client:ChatPrint("Status '" .. sDisplayName .. "' removed from target.")
		elseif not statTbl then
			client:ChatPrint("Invalid status effect.")
		elseif not charStatus then
			local sDisplayName = statTbl.name
			client:ChatPrint("Status '".. sDisplayName .."' not active on target.")
		end
	end
})

ix.command.Add("PlyCheckStatuses", {
	description = "Display all status effects active on target.",
	adminOnly = true,
	arguments = {ix.type.player},
	OnRun = function(self, client, target)
		local character = client:GetCharacter()
		if not character then return end

		local bHasStatuses = false
		local statusEffects = character:GetStatuses(character)
		
		for uniqueID, charStatus in pairs(statusEffects) do
			local statTbl = PLUGIN:GetStatusTable(uniqueID)
			local sDisplayName = statTbl.name
			client:ChatPrint(sDisplayName .. ": " .. (charStatus) .. "%")
			bHasStatuses = true
		end
		
		if !bHasStatuses then
			client:ChatPrint("No status effects active on target.")
		end
	end
})