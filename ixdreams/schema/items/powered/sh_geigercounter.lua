ITEM.name = "Geiger Counter"
ITEM.description = "A radiation dosimeter with a distinctive click."
ITEM.model = "models/lostsignalproject/items/devices/geiger.mdl"
ITEM.category = "Equipment"
ITEM.width = 1
ITEM.height = 1
ITEM.chargeLossRate = 1 -- Charge consumed per second when active
-- ITEM.chargeGainRate = 1 -- Charge regained per second wile charging. Only used when bPowerSupply = true
ITEM.batteryItem = "battery9v" -- Item required to recharge
--ITEM.bPowerSupply = true
ITEM.maxBatteries = 2


function ITEM:ToggleFunction()
	-- Get the owner of this item (the player holding the Geiger counter)
	local owner = self:GetOwner()
	if not IsValid(owner) then return end

	-- We'll accumulate an "intensity" value from all nearby radiation sources.
	-- The higher the total intensity, the more frequent the clicks.
	local totalIntensity = 0
	local pos = owner:GetPos()
	local detectionRadius = self:GetData("detectionRadius") or 512  -- units within which we “sense” radiation

	-- 1. Check for nearby radiation sources (entities of class "ix_radsource")
	for _, ent in pairs(ents.FindInSphere(pos, detectionRadius)) do
		local classname = ent:GetClass()
		if classname == "ix_radsource" then
			local distance = pos:Distance(ent:GetPos())
			if distance < 1 then distance = 1 end  -- prevent division by zero
			-- Assume a radsource has a net radiation value (default to 1 if not set)
			local rad = ent:GetNetVar("rads", 1)
			-- Intensity contribution diminishes with distance
			totalIntensity = totalIntensity + (rad / distance)
		elseif classname == "ix_item" then
			local item = ent:GetItemTable()
			if item and item:GetData("rads", 0) > 0 then
				local rad = item:GetData("rads", 0)
				local distance = pos:Distance(ent:GetPos())
				if distance < 1 then distance = 1 end
				totalIntensity = totalIntensity + (rad / distance)
			end
		elseif ent:IsPlayer() then
			if ent ~= owner and IsValid(ent) then
				local rad = ent:GetData("rads", 0)
				if rad > 0 then
					local distance = pos:Distance(ent:GetPos())
					if distance < 1 then distance = 1 end
					totalIntensity = totalIntensity + (rad / distance)
				end
			end
		end
	end

	-- -- 2. Check for nearby players who have radiation (via GetNetVar("rads", 0))
	-- -- Exclude the owner of the Geiger counter
	-- for _, ply in ipairs(player.GetAll()) do
		-- if ply ~= owner and IsValid(ply) then
			-- local rad = ply:GetNetVar("rads", 0)
			-- if rad > 0 then
				-- local distance = pos:Distance(ply:GetPos())
				-- if distance < 1 then distance = 1 end
				-- totalIntensity = totalIntensity + (rad / distance)
			-- end
		-- end
	-- end

	-- -- 3. Check for nearby items that have radiation (via item:GetData("rads", 0))
	-- for _, ent in ipairs(ents.FindInSphere(pos, detectionRadius)) do
		-- if ent:GetClass() == "ix_item" then
			-- local item = ent:GetItemTable()
			-- if item and item:GetData("rads", 0) > 0 then
				-- local rad = item:GetData("rads", 0)
				-- local distance = pos:Distance(ent:GetPos())
				-- if distance < 1 then distance = 1 end
				-- totalIntensity = totalIntensity + (rad / distance)
			-- end
		-- end
	-- end

	-- Determine the expected number of clicks per second.
	-- Adjust scalingFactor as needed to get realistic behavior.
	local scalingFactor = 0.2
	local expectedClicks = totalIntensity * scalingFactor

	-- Use a simple probabilistic method to get an integer number of clicks:
	local numClicks = math.floor(expectedClicks)
	if math.random() < (expectedClicks - numClicks) then
		numClicks = numClicks + 1
	end

	-- Schedule the click sounds within this one-second interval.
	-- If more than one click is generated, space them out evenly.
	if numClicks > 0 then
		for i = 1, numClicks do
			timer.Simple((i - 1) * (1 / numClicks), function()
				if IsValid(owner) then
					-- Pick one of the HL2 geiger counter sounds at random
					local soundChoice = "ambient/levels/canals/geiger" .. math.random(1, 3) .. ".wav"
					owner:EmitSound(soundChoice, 75, 100)
				end
			end)
		end
	end
end