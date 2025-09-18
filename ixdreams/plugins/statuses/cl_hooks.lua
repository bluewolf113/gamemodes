local PLUGIN = PLUGIN

if CLIENT then
	net.Receive("ixCharacterStatusChanged", function()
		local id = net.ReadUInt(32)		
		local character = ix.char.loaded[id]
		
		local uniqueID = net.ReadString()
		local scale = net.ReadFloat()

		if (character) then
			character.vars.statuses = character.vars.statuses or {}				
			local statuses = character.vars.statuses or {}
			
			local statusTbl = PLUGIN:GetStatusTable(uniqueID)
			local scaleMin = statusTbl.scaleMin or 0
			
			if scale == (scaleMin - 1) then
				statuses[uniqueID] = nil
			else
				statuses[uniqueID] = scale
			end
			
			character.vars.statuses = statuses
		end
	end)

	-- function PLUGIN:Think()
		-- for _, client in ipairs(player.GetAll()) do
			-- if client:IsValid() and client:Alive() then
				-- local character = client:GetCharacter()
				-- if not character then return end

				-- local statuses = character:GetData("statuses", {})

				-- for uniqueID, status in pairs(statuses) do
					-- if ix.statuses.list[uniqueID] then
						-- ix.statuses.list[uniqueID].OnThink(client, status.scale)
					-- end
				-- end
			-- end
		-- end
	-- end
end
