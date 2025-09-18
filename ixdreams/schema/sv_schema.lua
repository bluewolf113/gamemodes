
-- Here is where all of your serverside functions should go.

-- data saving
function Schema:SaveCookingSources()
	local data = {}

	for _, v in ipairs(ents.FindByClass("ix_cookingsource")) do
		data[#data + 1] = {v:GetPos(), v:GetAngles(), v:GetDisplayName(), v:GetDescription(), v:GetVisibleModel(), v:GetPoint()}
	end

	ix.data.Set("cookingSources", data)
end

-- data saving
function Schema:SaveFluidSources()
	local data = {}

	for _, v in ipairs(ents.FindByClass("ix_fluidsource")) do
		data[#data + 1] = {v:GetPos(), v:GetAngles(), v:GetDisplayName(), v:GetDescription(), v:GetType(), v:GetVisibleModel(), v:GetPoint(), v:GetAmountMax(), v:GetAmountLeft()}
	end

	ix.data.Set("fluidSources", data)
end

-- data saving
function Schema:SaveHints()
	local data = {}

	for _, v in ipairs(ents.FindByClass("ix_hint")) do
		data[#data + 1] = {v:GetPos(), v:GetDescription(), v:GetDrawRange(), v:GetEnabled()}
	end

	ix.data.Set("hints", data)
end

function Schema:SaveDeployedEntities()
	local data = {}

	for k, v in pairs(ix.item.deployedEntities) do
		if IsValid(k) and ix.item.instance[v] then
			data[#data + 1] = {k:GetClassname(), k:GetNetVar("ixDeployedItemID", ""), k:GetPos()}
		end
	end

	ix.data.Set("deployedEntities", data)
end

-- data loading
function Schema:LoadCookingSources()
	for _, v in ipairs(ix.data.Get("cookingSources") or {}) do
		local cSource = ents.Create("ix_cookingsource")

		cSource:SetPos(v[1])
		cSource:SetAngles(v[2])
		cSource:SetDisplayName(v[3])
		cSource:SetDescription(v[4])
		cSource:SetVisibleModel(v[5])
		cSource:SetPoint(v[6])
		
		cSource:Spawn()
	end
end

-- data loading
function Schema:LoadFluidSources()
	for _, v in ipairs(ix.data.Get("fluidSources") or {}) do
		local fSource = ents.Create("ix_fluidsource")

		fSource:SetPos(v[1])
		fSource:SetAngles(v[2])
		fSource:SetDisplayName(v[3])
		fSource:SetDescription(v[4])
		fSource:SetType(v[5])
		fSource:SetVisibleModel(v[6])
		fSource:SetPoint(v[7])
		fSource:SetAmountMax(v[8])
		fSource:SetAmountMax(v[9])
		
		fSource:Spawn()
	end
end

-- data loading
function Schema:LoadHints()
	for _, v in ipairs(ix.data.Get("hints") or {}) do
		local hint = ents.Create("ix_hint")

		hint:SetPos(v[1])
		hint:SetDescription(v[2])
		hint:SetDrawRange(v[3])
		
		hint:Spawn()
		hint:SetEnabled(v[4])
	end
end

function Schema:LoadDeployedEntities()
	for _, v in pairs(ix.data.Get("deployedEntities") or {}) do
		local ent = ents.Create(v[1])

		ent:SetNetVar("ixDeployedItemID", v[2])
		ent:SetPos(v[3])
		
		ent:Spawn()
		
		ix.item.deployedEntities[ent] = v[2]
	end
end

-- Example server function that will slap the given player.
function Schema:SlapPlayer(client)
	if (IsValid(client) and client:IsPlayer()) then
		client:SetVelocity(Vector(math.random(-50, 50), math.random(-50, 50), math.random(0, 20)))
		client:TakeDamage(math.random(5, 10))
	end
end

-- Items spawn in a player's inventory; if there is no more space, they spawn at the player's position
-- items can be either a number or a table of two numbers representing min/max of a random range

function Schema:SpawnItemsOnPlayer(player, items)
	local character = player:GetCharacter()
	if not character then return end
	
	local inventory = character:GetInventory()
	if not inventory then return end
	
	local items = istable(items) and table.Copy(items) or {[items] = 1}
	
	if istable(items) then	
		for item, quantityRange in pairs(items) do
			local iItemQuantity = 0
			local data
			if istable(quantityRange) then
				local iRangeMin = quantityRange[1]
				local iRangeMax = quantityRange[2] or iRangeMin
				
				iItemQuantity = math.ceil(math.random(iRangeMin - 0.99, iRangeMax))
				
				data = quantityRange.data or quantityRange[3]
			else
				iItemQuantity = quantityRange
			end
			
			for i = 1, iItemQuantity do
				if not (inventory:Add(item, 1, data)) then
					ix.item.Spawn(item, player:GetPos(), function(item, entity)
						if item and entity then 
							entity:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR) 
							entity:GetPhysicsObject():RecheckCollisionFilter() 
							entity:GetPhysicsObject():SetVelocityInstantaneous(Vector(0,0,0)) 
						else 
							return 
						end 
					end, nil, data ) 
				end
			end
		end
	end
end