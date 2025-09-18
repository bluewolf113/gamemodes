-- META REDEFINITIONS
-- META REDEFINITIONS
-- META REDEFINITIONS
-- META REDEFINITIONS

do

-- inventory meta function redefinitions

	local META = ix.meta.inventory
	
	-- redefine CanItemFit to include an override

	function META:CanItemFit(x, y, w, h, item2, bOverride, endX, endY)
		local canFit = true
		local endX = endX or self.w
		local endY = endY or self.h
		
		print("META:CanItemFit: self.w = " .. tostring(self.w) .. ", self.h = " .. tostring(self.h))
		
		

		for x2 = 0, w - 1 do
			for y2 = 0, h - 1 do
				local item = (self.slots[x + x2] or {})[y + y2]
				
				if not bOverride and (((y + y2 > endY) or ((x + x2) > endX)) or item) then
					if (item2) then
						if (item and item.id == item2.id) then
							print("META:CanItemFit: (item and item.id == item2.id) = " .. tostring((item and item.id == item2.id)))
							continue
						end
					end
					canFit = false
					print("META:CanItemFit: canFit = " .. tostring(canFit))
					break
				end
			end

			if (!canFit) then
				break
			end
		end

		return canFit
	end
	
	-- redefine Remove to iterate over slots instead of by w, h
	
	function META:Remove(id, bNoReplication, bNoDelete, bTransferring)
		local x2, y2

		for x, col in pairs (self.slots) do
			for y, item in pairs(col) do

				if (item and item.id == id) then
					self.slots[x][y] = nil

					x2 = x2 or x
					y2 = y2 or y
				end
			end
		end

		if (SERVER and !bNoReplication) then
			local receivers = self:GetReceivers()

			if (istable(receivers)) then
				net.Start("ixInventoryRemove")
					net.WriteUInt(id, 32)
					net.WriteUInt(self:GetID(), 32)
				net.Send(receivers)
			end

			-- we aren't removing the item - we're transferring it to another inventory
			if (!bTransferring) then
				hook.Run("InventoryItemRemoved", self, ix.item.instances[id])
			end

			if (!bNoDelete) then
				local item = ix.item.instances[id]

				if (item and item.OnRemoved) then
					item:OnRemoved()
				end

				local query = mysql:Delete("ix_items")
					query:Where("item_id", id)
				query:Execute()

				ix.item.instances[id] = nil
			end
		end

		return x2, y2
	end
	
	-- redefine FindEmptySlot to contain additional search parameters
	
	function META:FindEmptySlot(w, h, onlyMain, startX, startY, endX, endY)
		w = w or 1
		h = h or 1
		
		local startingX = startX or 1
		local startingY = startY or 1
		
		local endX = endX or self.w
		local endY = endY or self.h
		
		local endingX = endX - (w - 1)
		local endingY = endY - (h - 1)
		
		print("META:FindEmptySlot: endingX = " .. tostring(endingX) .. ", endingY = " .. tostring(endingY))
		print("META:FindEmptySlot: endX = " .. tostring(endX) .. ", endY = " .. tostring(endY))

		if (w > self.w or h > self.h) then
			print("META:FindEmptySlot: (w > self.w or h > self.h)")
			return
		end
		
		-- we can search the whole inventory or a specific subset of the slots. useful for crafting, where items must be inserted at slot positions > w, h

		for x = startingX, endingX do		
			for y = startingY, endingY do
				print("META:FindEmptySlot: startingX = " .. tostring(startingX) .. ", startingY = " .. tostring(startingY))
				if (self:CanItemFit(x, y, w, h, {}, false, endX, endY)) then
					return x, y
				end
			end
		end

		if (onlyMain != true) then
			local bags = self:GetBags()

			if (#bags > 0) then
				for _, invID in ipairs(bags) do
					local bagInv = ix.item.inventories[invID]

					if (bagInv) then
						local x, y = bagInv:FindEmptySlot(w, h)

						if (x and y) then
							return x, y, bagInv
						end
					end
				end
			end
		end
	end
	
	ix.meta.inventory = META

end

do

	-- item meta redefinitions

	local META = ix.meta.item
	
		function META:DoTimedAction(text, time, callback, startTime, finishTime)
		if (time and time <= 0) then
			if (callback) then
				callback(self)
			end

			return
		end

		-- Default the time to five seconds.
		time = time or 5
		startTime = startTime or CurTime()
		finishTime = finishTime or (startTime + time)

		if (text == false) then
			timer.Remove("ixAct"..self:UniqueID())

			net.Start("ixActionBarReset")
			net.Send(self)

			return
		end

		if (!text) then
			net.Start("ixActionBarReset")
			net.Send(self)
		else
			net.Start("ixActionBar")
				net.WriteFloat(startTime)
				net.WriteFloat(finishTime)
				net.WriteString(text)
			net.Send(self)
		end

		-- If we have provided a callback, run it delayed.
		if (callback) then
			-- Create a timer that runs once with a delay.
			timer.Create("ixAct"..self:UniqueID(), time, 1, function()
				-- Call the callback if the player is still valid.
				if (IsValid(self)) then
					callback(self)
				end
			end)
		end
	end
	
	--- Changes the function called on specific events for the item.
	-- @realm shared
	-- @string name The name of the hook
	-- @func func The function to call once the event occurs
	function META:Hook(eventName, identifier, func)
		print("META:Hook: self.uniqueID = " .. tostring(self.uniqueID))
		print("META:Hook: eventName = " .. tostring(eventName))
		print("META:Hook: self.hooks[eventName] = " .. tostring(self.hooks[eventName]))
		
		if (eventName and identifier) then
		
			self.hooks[eventName] = self.hooks[eventName] or {}
			
			-- backwards compatibility
			if isfunction(identifier) and not func then
				local newIdentifier = eventName .. "_" .. tostring(#self.hooks[eventName])
				
				self.hooks[eventName][newIdentifier] = identifier
				return
			end
		
			self.hooks[eventName][identifier] = func
		end
	end

	--- Changes the function called after hooks for specific events for the item.
	-- @realm shared
	-- @string name The name of the hook
	-- @func func The function to call after the original hook was called
	function META:PostHook(eventName, identifier, func)
		if (eventName and identifier) then
			self.postHooks[eventName] = self.postHooks[eventName] or {}
			-- backwards compatibility
			if isfunction(identifier) and not func then
				local newIdentifier = eventName .. "_" .. tostring(#self.postHooks[eventName])
				
				self.postHooks[eventName][newIdentifier] = identifier
				return
			end
			
			self.postHooks[eventName][identifier] = func
		end
	end

	function META:OnInstanced(invID, x, y, item)
		-- print("META:OnInstanced: entered")
		if self.hooks["OnInstanced"] then
			-- print("META:OnInstanced: self.hooks[OnInstanced] = " .. tostring(self.hooks["OnInstanced"]))
			if istable(self.hooks["OnInstanced"]) then
				-- print("META:OnInstanced: istable(self.hooks[OnInstanced]) = true")
				local result
				for k, v in pairs(self.hooks["OnInstanced"]) do
					result = v(invID, x, y, self, self.data)
					
					-- print("META:OnInstanced: k = " .. tostring(k) .. ", v = " .. tostring(v))
					
					if result then break end
				end
			end
		end
		
		-- random item models
		-- select model from a table and save the index if istable(self.model)
		if istable(item.model) and not item:GetData("modelIndex", nil) then
			local index = math.random(1, #item.model)		
			item:SetData("modelIndex", index)
			
			if SERVER then
				-- re-initialize model and collisions when spawned in the world
				local entity = item:GetEntity()
				if entity and IsValid(entity) then
					entity:SetModel(item:GetModel())
					
					entity:PhysicsInit(SOLID_VPHYSICS)
					entity:SetSolid(SOLID_VPHYSICS)
					
					local physObj = entity:GetPhysicsObject()		

					if (!IsValid(physObj)) then
						local invalidBoundsMin = Vector(-8, -8, -8)
						local invalidBoundsMax = Vector(8, 8, 8)
						
						entity:PhysicsInitBox(invalidBoundsMin, invalidBoundsMax)
						entity:SetCollisionBounds(invalidBoundsMin, invalidBoundsMax)
					end
					
					if (IsValid(physObj)) then
						physObj:EnableMotion(true)
						physObj:Wake()
					end
				end
			end
		end
		
		if self.postHooks["OnInstanced"] then
			if istable(self.postHooks["OnInstanced"]) then	
				local result
				for k, v in pairs(self.postHooks["OnInstanced"]) do
					result = v(invID, x, y, self, self.data)
					
					if result then break end
				end
			end
		end
		
		print("OnInstanced: end of function reached")
	end
	
	function META:OnRegistered()

		if istable(self.hooks["OnRegistered"]) then
			local result
			
			for k, v in pairs(self.hooks["OnRegistered"]) do
				result = v(self, self.data)
				
				if result then break end
			end
		end
	
		if istable(self.postHooks["OnRegistered"]) then
			local result
			for k, v in pairs(self.postHooks["OnRegistered"]) do
				result = v(self, self.data)
				
				if result then break end
			end
		end
	end
	
	function META:OnRemoved()
		
		if istable(self.hooks["OnRemoved"]) then
			local result
			
			for k, v in pairs(self.hooks["OnRemoved"]) do
				result = v(self, self.data)
				
				if result then break end
			end
		end
	

		if istable(self.postHooks["OnRemoved"]) then
			local result
			
			for k, v in pairs(self.postHooks["OnRemoved"]) do
				result = v(self, self.data)
				
				if result then break end
			end
		end
		
	end
	
	function META:OnSendData()
	
		if istable(self.hooks["OnSendData"]) then
			local result
			for k, v in pairs(self.hooks["OnSendData"]) do
				result = v(self, self.data)
				
				if result then break end
			end
		end
	

		if istable(self.postHooks["OnSendData"]) then
			local result
			for k, v in pairs(self.postHooks["OnSendData"]) do
				result = v(self, self.data)
				
				if result then break end
			end
		end
	
	end
	
	function META:OnTransferred(curInv, inventory)
	
		if istable(self.hooks["OnTransferred"]) then
			local result
			for k, v in pairs(self.hooks["OnTransferred"]) do
				result = v(curInv, inventory, self, self.data)
				
				if result then break end
			end
		end
	

		if istable(self.postHooks["OnTransferred"]) then
			local result
			for k, v in pairs(self.postHooks["OnTransferred"]) do
				result = v(curInv, inventory, self, self.data)
				
				if result then break end
			end
		end
	
	end
	
	function META:OnEntityCreated(item)
	
		if istable(self.hooks["OnEntityCreated"]) then
			local result
			for k, v in pairs(self.hooks["OnEntityCreated"]) do
				result = v(self, self.data)
				
				if result then break end
			end
		end
	

		if istable(self.postHooks["OnEntityCreated"]) then
			local result
			for k, v in pairs(self.postHooks["OnEntityCreated"]) do
				result = v(self, self.data)
				
				if result then break end
			end
		end
	
	end
	
	function META:OnEntityTakeDamage(item, damageInfo)
	
		if istable(self.hooks["OnEntityTakeDamage"]) then
			local result
			for k, v in pairs(self.hooks["OnEntityTakeDamage"]) do
				result = v(damageInfo, self, self.data)
				
				if result then break end
			end
		end
	

		if istable(self.postHooks["OnEntityTakeDamage"]) then
			local result
			for k, v in pairs(self.postHooks["OnEntityTakeDamage"]) do
				result = v(damageInfo, self, self.data)
				
				if result then break end
			end
		end
	
	end
	
	function META:OnDestroyed(item)
	
		if istable(self.hooks["OnDestroyed"]) then
			local result
			for k, v in pairs(self.hooks["OnDestroyed"]) do
				result = v(self, self.data)
				
				if result then break end
			end
		end
	

		if istable(self.postHooks["OnDestroyed"]) then
			local result
			for k, v in pairs(self.postHooks["OnDestroyed"]) do
				result = v(self, self.data)
				
				if result then break end
			end
		end
	
	end
	
	function META:GetModel()
		if istable(self.model) then
			local index = self:GetData("modelIndex", 1)
			return self.model[index]
		else
			return self.model
		end
	end
	
	function META:GetBodygroups()
		return {}
	end
	
	function META:GetSubMaterial()
		return {}
	end
	
	-- redefine transfer() to tag an item if it is logical
	
	function META:Transfer(invID, x, y, client, noReplication, isLogical)
		invID = invID or 0

		if (self.invID == invID) then
			return false, "same inv"
		end

		local inventory = ix.item.inventories[invID]
		local curInv = ix.item.inventories[self.invID or 0]

		if (curInv and !IsValid(client)) then
			client = curInv.GetOwner and curInv:GetOwner() or nil
		end

		-- check if this item doesn't belong to another one of this player's characters
		local itemPlayerID = self:GetPlayerID()
		local itemCharacterID = self:GetCharacterID()

		if (!self.bAllowMultiCharacterInteraction and IsValid(client) and client:GetCharacter()) then
			local playerID = client:SteamID64()
			local characterID = client:GetCharacter():GetID()

			if (itemPlayerID and itemCharacterID) then
				if (itemPlayerID == playerID and itemCharacterID != characterID) then
					return false, "itemOwned"
				end
			else
				self.characterID = characterID
				self.playerID = playerID

				local query = mysql:Update("ix_items")
					query:Update("character_id", characterID)
					query:Update("player_id", playerID)
					query:Where("item_id", self:GetID())
				query:Execute()
			end
		end

		if (hook.Run("CanTransferItem", self, curInv, inventory) == false) then
			return false, "notAllowed"
		end

		local authorized = false

		if (inventory and inventory.OnAuthorizeTransfer and inventory:OnAuthorizeTransfer(client, curInv, self)) then
			authorized = true
		end

		if (!authorized and self.CanTransfer and self:CanTransfer(curInv, inventory) == false) then
			return false, "notAllowed"
		end

		if (curInv) then
			if (invID and invID > 0 and inventory) then
				local targetInv = inventory
				local bagInv

				if (!x and !y) then
					x, y, bagInv = inventory:FindEmptySlot(self.width, self.height)
				end

				if (bagInv) then
					targetInv = bagInv
				end

				if (!x or !y) then
					return false, "noFit"
				end

				local prevID = self.invID
				local status, result = targetInv:Add(self.id, nil, nil, x, y, noReplication)

				if (status) then
					if (self.invID > 0 and prevID != 0) then
						-- we are transferring this item from one inventory to another
						curInv:Remove(self.id, false, true, true)

						if (self.OnTransferred) then
							self:OnTransferred(curInv, inventory)
						end

						hook.Run("OnItemTransferred", self, curInv, inventory)
						return true
					elseif (self.invID > 0 and prevID == 0) then
						-- we are transferring this item from the world to an inventory
						ix.item.inventories[0][self.id] = nil

						if (self.OnTransferred) then
							self:OnTransferred(curInv, inventory)
						end

						hook.Run("OnItemTransferred", self, curInv, inventory)
						return true
					end
				else
					return false, result
				end
			elseif (IsValid(client)) then
				-- we are transferring this item from an inventory to the world
				self.invID = 0
				curInv:Remove(self.id, false, true)

				local query = mysql:Update("ix_items")
					query:Update("inventory_id", 0)
					query:Where("item_id", self.id)
				query:Execute()

				inventory = ix.item.inventories[0]
				inventory[self:GetID()] = self

				if (self.OnTransferred) then
					self:OnTransferred(curInv, inventory)
				end

				hook.Run("OnItemTransferred", self, curInv, inventory)
				
				self.bLogical = isLogical

				if (!isLogical) then
					return self:Spawn(client)
				end

				return true
			else
				return false, "noOwner"
			end
		else
			return false, "invalidInventory"
		end
	end
	
	ix.meta.item = META
	
end



-- META REDEFINITIONS ABOVE THIS LINE
-- META REDEFINITIONS ABOVE THIS LINE
-- META REDEFINITIONS ABOVE THIS LINE
-- META REDEFINITIONS ABOVE THIS LINE

Schema.name = "λ"
Schema.description = "ancillary"
Schema.author = "Electric Dreams"   
Schema.banner = "title.png"

ix.util.Include("cl_schema.lua")
ix.util.Include("sv_schema.lua")

ix.util.Include("cl_hooks.lua")
ix.util.Include("sh_hooks.lua")
ix.util.Include("sv_hooks.lua")

ix.util.Include("cl_skin.lua")

ix.util.Include("libs/thirdparty/sh_netstream2.lua")

ix.util.Include("meta/sh_character.lua")
ix.util.Include("meta/sh_player.lua")

ix.util.Include("libs/needs/sh_needs.lua")
ix.util.Include("libs/crafting/sh_crafting.lua")
ix.util.Include("libs/cl_hints.lua")

ix.currency.symbol = ""
ix.currency.singular = "token"
ix.currency.plural = "tokens"
ix.currency.model = "models/props/cs_assault/money.mdl"

function Schema:PlayerNearEntities(player, entity, distance, count, bReturnEntities)
    if not player or not entity then return end
	
	local targetEntities = {}
	local foundEntities = {}
	local playerPos = player:GetPos()
	local entsInSphere = ents.FindInSphere(playerPos, distance)
	
	if istable(entity) then
		targetEntities = entity
	else
		if not count then count = 1 end
		if not distance then distance = 1000 end
		
		targetEntities[entity] = count
	end
    
    for ent, count in pairs(targetEntities) do
		if IsValid(ent) then
			local entityClass = ent:GetClass()
			local bIsItemTable = entityClass == "ix_item"
			
			for _, v in pairs(entsInSphere) do
				if bIsItemTable then
					-- If entity is an itemTable or its class is ix_item, compare item IDs
					if v:GetClass() == "ix_item" and v:GetItemID() == entity:GetItemID() then
						table.insert(foundEntities, v)
					end
				else
					-- Otherwise, compare the classnames
					if v:GetClass() == entityClass then
						table.insert(foundEntities, v)
					end
				end
			end		
		end
		
	end   
    
    if #foundEntities >= count then
        if bReturnEntities then
            if bIsItemTable then
                -- Return table of item IDs
                local itemIDs = {}
                for _, v in ipairs(foundEntities) do
                    table.insert(itemIDs, v:GetItemID())
                end
                return itemIDs
            else
                -- Return table of entities
                return foundEntities
            end
        end
        return true
    end
    
    return false
end

function Schema:GetNearestEntity(player, entity, conditions)
	if not IsValid(player) then return nil end
	conditions = conditions or {}

    local nearestEnt = nil
    local nearestDist = 99999999 -- Initialize with a very large distance

    for _, ent in pairs(ents.FindByClass(entity)) do
        -- Check if the entity is valid
        if IsValid(ent) then
            -- Calculate the distance from the player to the entity
			local varsTbl = ent:GetNetworkVars()
			
			for k, v in pairs(conditions) do
				if not varsTbl[k] == v then
					goto skip
				end
			end
			
            local dist = player:GetPos():Distance(ent:GetPos())
            
            -- Check if this entity is closer than the previously found entity
            if dist < nearestDist then
                nearestDist = dist
                nearestEnt = ent
            end
			
			::skip::
        end
    end

    return nearestEnt
end

-- Data tables for refillable item contents

ix.item.containerContents = {}

do
	local CC = {}
	
	CC.displayName = "Water"
	CC.uniqueID = "water_clean"
	CC.drink = "Refreshing. The stuff of all life."
	CC.thirst = 20
	
	function CC:GetStatusEffects()
		return {}
	end

	-- function CC:OnFill(character) end
	-- function CC:OnEmpty(character) end
	
	ix.item.containerContents[CC.uniqueID] = CC
end

do
	local CC = {}
	
	CC.displayName = "Water"
	CC.uniqueID = "water_irradiated"
	CC.drink = "Refreshing. The stuff of all life."
	CC.thirst = 20
	
	function CC:GetStatusEffects()
		return {}
	end
	
	ix.item.containerContents[CC.uniqueID] = CC
end

do
	local CC = {}
	
	CC.displayName = "Water, polluted"
	CC.uniqueID = "water_polluted"
	CC.drink = "You swallow bits of dirt and gunk."
	CC.thirst = 12
	
	function CC:GetStatusEffects()
		return {}
	end
	
	ix.item.containerContents[CC.uniqueID] = CC
end

do
	local CC = {}
	
	CC.displayName = "Water, oceanic"
	CC.uniqueID = "water_ocean"
	CC.drink = "Your stomach turns. Your mouth shrivels like leather. Why would you even do that?"
	CC.thirst = -15
	
	function CC:GetStatusEffects()
		return {}
	end
	
	ix.item.containerContents[CC.uniqueID] = CC
end

function Schema:PlayerNearFluidSource(player, distance)
    if not player then return false end
    if not distance then distance = 20^2 end
	if distance < 0 then distance = 9999^2 end
	
	local sourceEntity = player:GetEyeTrace().Entity:GetClass() == "ix_fluidsource" and player:GetEyeTrace().Entity
	
	if sourceEntity then
		local playerPos = player:GetPos()
		local sourcePos = sourceEntity:GetPos()
		local bWithinDistance = playerPos:DistanceSqr(sourcePos) <= distance
		
		if sourceEntity and bWithinDistance then
			return sourceEntity
		end	
	end

    -- Check if the player is in water
    local bIsInWater = player:WaterLevel() > 0
	
	if bIsInWater then 
		local nearestPointSource = Schema:GetNearestEntity(player, "ix_fluidsource", {["Point"] = true})
		return nearestPointSource
	end

    -- -- Check if the player is looking directly at a water brush within a certain distance
    -- local eyePos = player:EyePos()
    -- local eyeAngles = player:EyeAngles()
    -- local forward = eyeAngles:Forward()
    -- local trace = util.TraceLine({
        -- start = eyePos,
        -- endpos = eyePos + forward * distance,
        -- filter = player
    -- })

    -- local isNearWaterBrush = trace.Hit and trace.HitTexture and string.find(trace.HitTexture, "water") and trace.Fraction * distance <= 1000	
	-- if isNearWaterBrush then return isNearWaterBrush end
	
	return false
end

do
	
	if CLIENT then
		function ix.item.DrawActionBars()
			for k, v in pairs(ix.item.timers or {}) do
				local item = ix.item.instances[k]
				
				if item and item:GetInventory() then
					ix.item.DrawActionBar()
				end
			end
		end
	
		function ix.item.DrawActionBar(item)
			local start, finish = ix.bar.actionStart, ix.bar.actionEnd
			local curTime = CurTime()
			local scrW, scrH = ScrW(), ScrH()

			if (finish > curTime) then
				local fraction = 1 - math.TimeFraction(start, finish, curTime)
				local alpha = fraction * 255

				if (alpha > 0) then
					local w, h = scrW * 0.35, 28
					local x, y = (scrW * 0.5) - (w * 0.5), (scrH * 0.725) - (h * 0.5)

					ix.util.DrawBlurAt(x, y, w, h)

					surface.SetDrawColor(35, 35, 35, 100)
					surface.DrawRect(x, y, w, h)

					surface.SetDrawColor(0, 0, 0, 120)
					surface.DrawOutlinedRect(x, y, w, h)

					surface.SetDrawColor(ix.config.Get("color"))
					surface.DrawRect(x + 4, y + 4, math.max(w * fraction, 8) - 8, h - 8)

					surface.SetDrawColor(200, 200, 200, 20)
					surface.SetMaterial(gradientD)
					surface.DrawTexturedRect(x + 4, y + 4, math.max(w * fraction, 8) - 8, h - 8)

					draw.SimpleText(ix.bar.actionText, "ixMediumFont", x + 2, y - 22, SHADOW_COLOR)
					draw.SimpleText(ix.bar.actionText, "ixMediumFont", x, y - 24, TEXT_COLOR)
				end
			end
		end
	end

end


-- Viewbob, going to move this somewhere later

local bobIntensity = 0.04    -- Bobbing strength
local bobFrequency = 12    -- Oscillation speed
local smoothingFactor = 0.2 -- Damping factor for smoothing
local previousBobOffset = 0 -- Store the previous frame's bob offset

local function GetViewBobOffset(ply)
    local speed = ply:GetVelocity():Length2D()
    local maxSpeed = ply:IsSprinting() and ply:GetRunSpeed() or ply:GetWalkSpeed()
	local bobFrequency = ply:IsSprinting() and bobFrequency * 1.5 or bobFrequency

    -- Normalize speed to a value between 0 and 1
    local speedFactor = math.Clamp(speed / maxSpeed, 0, 1)

    -- Calculate raw bobbing based on time and speed
    local time = CurTime() * bobFrequency
    local rawBobOffset = math.sin(time) * bobIntensity * speedFactor

    -- Apply smoothing with lerp
    local smoothedBobOffset = Lerp(smoothingFactor, previousBobOffset, rawBobOffset)
    previousBobOffset = smoothedBobOffset

    return smoothedBobOffset
end

local function DoViewBob(ply, pos, angles, fov)
	if ply:GetMoveType() == MOVETYPE_NOCLIP then 
		return {
			origin = pos,
			angles = angles,
			fov = fov
			} 
	end
    local bobOffset = GetViewBobOffset(ply)

    -- Apply the bobbing to the view angles (pitch and roll)
    angles.pitch = angles.pitch + bobOffset
    angles.roll = angles.roll + bobOffset * 0.5

    -- Optionally, apply bobbing to the view position (up and down)
    pos.z = pos.z + bobOffset

    return {
        origin = pos,
        angles = angles,
        fov = fov
    }
end

if CLIENT then
	if ix.config.Get("enableViewBob", false) then
		hook.Add("CalcView", "CustomViewBob", DoViewBob)
	end
end

ix.config.Add("enableViewBob", false, "Enable viewbob.", function(oldValue, newValue) 
		if CLIENT then
			if newValue and not oldValue then
				print("Attempting add hook")
				hook.Add("CalcView", "CustomViewBob", DoViewBob)
			elseif oldValue and not newValue then
				hook.Remove("CalcView", "CustomViewBob")
			end
		end
	end, {
	category = "server"
}, false, true)