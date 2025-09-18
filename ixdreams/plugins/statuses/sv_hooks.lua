local PLUGIN = PLUGIN

-- Reload any existing status effects

function PLUGIN:PlayerLoadedCharacter(client, curChar, prevChar)
	if not curChar then return end

	local statuses = PLUGIN:GetStatusesTable()
	
	for _, status in pairs(statuses) do	
	
		if not status or not status.uniqueID then return end
		
		local uniqueID = status.uniqueID		
		local charStatus = curChar:GetStatusEffect(uniqueID)
		local bCharacterAdded = false
		
		if charStatus then 
			if not bCharacterAdded then 
				PLUGIN:AddActiveCharacter(curChar)
				bCharacterAdded = true
			end
			
			curChar:SetStatusEffect(uniqueID, charStatus)
		end
	end
end

-- Remove any status effects from last character

function PLUGIN:PrePlayerLoadedCharacter(client, curChar, prevChar)
	if not prevChar then return end

	local statuses = PLUGIN:GetStatusesTable()
	
	for _, status in pairs(statuses) do	
	
		if not status or not status.uniqueID then print("status or status.uniqueID nil") return end
		
		local uniqueID = status.uniqueID		
		local charStatus = prevChar:GetStatusEffect(uniqueID)
		local statusTbl = PLUGIN:GetStatusTable(uniqueID)
		local bCharacterRemoved = false
		
		if charStatus then 
			if not bCharacterRemoved then 
				PLUGIN:RemoveActiveCharacter(curChar)
				bCharacterRemoved = true
			end
		
			statusTbl:OnRemove(client, charStatus)
		end
	end
end

-- Network status table to client

if SERVER then
	util.AddNetworkString("ixCharacterStatusChanged")

	function PLUGIN:Think()
		if ( self.nextRun and self.nextRun > CurTime() ) then
			return
		end
		
		local activeChars = PLUGIN:GetActiveCharacters()
		
		for _, character in pairs(activeChars) do
			local client = character:GetPlayer()			
			
			if not client then PLUGIN:RemoveActiveCharacter(character:GetID()) return end
			
			local cCurrentChar = client:GetCharacter()
			
			if not cCurrentChar then return end
			
			local id = cCurrentChar:GetID()
			
			if id == character:GetID() then	
				local statuses = cCurrentChar:GetStatuses(cCurrentChar)

				for uniqueID, charStatusScale in pairs(statuses) do
					local status = PLUGIN:GetStatusTable(uniqueID)

					if charStatusScale then
						local scaleMin = status.scaleMin or 0
						local scaleMax = status.scaleMax or 100
						
						if charStatusScale <= scaleMin then
							character:RemoveStatusEffect(uniqueID)
						else
							status:OnThink(client, charStatusScale)
						end
					end
				end
			end	
		end
		
		self.nextRun = CurTime() + 1 -- 1 second delay
	end
end
