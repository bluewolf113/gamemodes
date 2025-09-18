local Schema = Schema

if SERVER then
    
    -- Initialize needs on character creation
	function ix.needs.OnCharacterCreated(client, character)
		if not client or not character then return end
		
		local needTbls = ix.needs.GetAll()
		for uniqueID, needTbl in pairs(needTbls) do
			if ix.needs.CharacterHasNeed(uniqueID, character) then
				local default = ix.needs.Get(uniqueID).defaultValue or 100
				character:SetNeed(uniqueID, default)	
			end
		end
	end

	
	function ix.needs.OnCharacterDisconnect(client, character)
		if not client or character then return end
		if timer.Exists("ixNeedDecayTimer_" .. character:GetID()) then
			timer.Remove("ixNeedDecayTimer_" .. character:GetID())
		end
	end
	
	function ix.needs.PlayerLoadedCharacter(client, curChar, prevChar)
		if not curChar then return end
		
		if prevChar and timer.Exists("ixNeedDecayTimer_" .. prevChar:GetID()) then
			timer.Remove("ixNeedDecayTimer_" .. prevChar:GetID())
		end
		
		local charNeedsTbl = {}

		local needTbls = ix.needs.GetAll()
		for uniqueID, needTbl in pairs(needTbls) do
		
			if ix.needs.CharacterHasNeed(uniqueID, curChar) then
				local nextRun = CurTime() + curChar:GetData("decayRate_" .. uniqueID, ix.needs.Get(uniqueID).decayRate or 1)
				
				charNeedsTbl[uniqueID] = nextRun
			end
		end
		
		local function decayNeeds()

			if ix.char.loaded[curChar:GetID()] then

				local curTime = CurTime()
				
				for uniqueID, nextRun in pairs(charNeedsTbl) do

					if nextRun <= CurTime() then

						local decayValue = curChar:GetData("decayValue_" .. uniqueID, ix.needs.Get(uniqueID).decayValue)
						local decayRate = curChar:GetData("decayRate_" .. uniqueID, ix.needs.Get(uniqueID).decayRate or 1)
					
						if ix.needs.Get(uniqueID).Think then
							ix.needs.Get(uniqueID):Think(client, curChar)
						end
						
						curChar:AddNeed(uniqueID, -1 * (decayValue / 60))
						
						charNeedsTbl[uniqueID] = CurTime() + 1
					end
				end
			end
		end
		
		timer.Create("ixNeedDecayTimer_" .. curChar:GetID(), 1, 0, decayNeeds)
	end
end