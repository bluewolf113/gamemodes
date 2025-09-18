ITEM.name = "Powered Base"
ITEM.description = "A base for electronic equipment."
ITEM.model = "models/props_lab/reciever01b.mdl"
ITEM.category = "Equipment"
ITEM.width = 1
ITEM.height = 1
ITEM.chargeLossRate = 1 -- Charge consumed per second when active
-- ITEM.chargeGainRate = 1 -- Charge regained per second wile charging. Only used when bPowerSupply = true
ITEM.batteryItem = "battery" -- Item required to recharge
--ITEM.bPowerSupply = true
--ITEM.maxBatteries = 1
 
-- types: battery; power supply


ITEM.functions.Toggle = {
	OnRun = function(item)
		local client = item.player
		
		if not client then return end
		
		local bIsOn = item:GetData("isOn")
		
		item:SetData("isOn", not bIsOn)
		
		bIsOn = item:GetData("isOn")
		
		if bIsOn then
			item:SetupTimer()
		else
			item:RemoveTimer()
		end
		
		local tblSoundParams = (item.sound and stable(item.sound["toggle"]) and item.sound["toggle"]) or {item.sound and item.sound["combine"] or "buttons/lightswitch2.wav", 75, 70, 1.0}
		client:EmitSound(unpack(tblSoundParams))
			
		return false
	end,
	
	OnCanRun = function(item)
		local bCanToggle = true
		
		if item.bPowerSupply then
			bCanToggle = item:GetData("charge", 0) > 0
		else
			for i = 1, (item.maxBatteries or 1) do
				local key = "battery_" .. tostring(i)
				local batItemID = item:GetData(key)
				local batItem = ix.item.instances[batItemID]
				
				if batItem and batItem:GetData("charge", 0) > 0 then
					continue
				else
					bCanToggle = false
					break
				end
			end 
		end
		
		return bCanToggle and (item.CanPlayerToggle and item:GetPlayerToggle() or true)
	end
}

function ITEM:CheckCharge()
	if item:GetData("isOn", false) then	
		if item.bPowerSupply then	
			local curCharge = item:GetData("charge", 0)
			
			if curCharge <= 0 then
				item:SetData("isOn", false)
			else
				item:SetData("charge", math.max(item.charge - (item.chargeLossRate or 1), 0))
			end
		else	
			for i = 1, (item.maxBatteries or 1) do
				local key = "battery_" .. tostring(i)
				local batItemID = item:GetData(key)
				
				if batItemID then
					local batItem = ix.item.instances[batItemID]
					local curCharge = batItem:GetData("charge", 0)
					
					if curCharge > 0 then
						batItem:SetData("charge", math.max(curCharge - (item.chargeLossRate or 1), 0))
						continue
					end
				end
				
				item:SetData("isOn", false)
			end 
		end       
	end
end

function ITEM:SetupTimer()
	local id = self:GetID()
	local timerID = "ixPoweredItemTimer_" .. tostring(id)
	
	local function DoEquipmentFunction()
		local item = ix.item.instances[id]
		
		if item.ToggleFunction then
			item:ToggleFunction()
		end
	end
	
	local function DoCheckCharge()
		local item = ix.item.instances[id]
		
		if item.CheckCharge then
			item:CheckCharge()
		end
	end
	
	timer.Create(timerID, 1, 0, function() DoCheckCharge() DoEquipmentFunction() end)
end

function ITEM:RemoveTimer()
	local id = self:GetID()
	local timerID = "ixPoweredItemTimer_" .. tostring(id)
	
	if timer.Exists(timerID) then
		timer.Remove(timerID)
	end
end

ITEM.functions.Batteries = {
	name = ITEM.batteriesFuncName or "Batteries",
	isMulti = true,
	multiOptions = function(item)
		local targets = {}
		local targetItem
		
		for i = 1, (item.maxBatteries or 1) do
			local key = "battery_" .. tostring(i)
			local batItemID = item:GetData(key)	

			targetItem = batItemID and ix.item.instances[batItemID]

			-- print("batItemID = " .. tostring(batItemID))

			targets[#targets + 1] = {
				name = (targetItem and targetItem:GetName()) or "Empty",
				data = (batItemID and {batItemID, key}) or nil
			}
		end

		return targets
	end,
	OnRun = function(item, data)
		if (!istable(data) or !data[2]) then return false end
		if (!ix.item.instances[data[1]]) then return false end
		
		local client = item.player
		
		if not client then print("Batteries.OnRun: client = nil") return end
		
		local character = client:GetCharacter()
		local invID = character:GetInventory():GetID()
		
		local batItemID = data[1]
		local key = data[2]
		local batItem = ix.item.instances[batItemID]
		
		print("Batteries.OnRun: batItem = " .. tostring(batItem))
		
		if not batItem:Transfer(invID, nil, nil, client) then
			-- batItem:Transfer(nil, nil, nil, client)
			 
			 local itemEntity = batItem:Spawn(client)
			itemEntity.ixItemID = itemID

			local physicsObject = itemEntity:GetPhysicsObject()

			if (IsValid(physicsObject)) then
				physicsObject:EnableMotion(true)
			end
		end
		
		item:SetData(key, nil)

		return false
	end,
	
	OnCanRun = function(item)
		return true
	end
}

ITEM.functions.combine = {
	OnRun = function(item, data)
		local ply = item.player
		local other = ix.item.instances[data[1]]
		
		if not ply or not item or not other then print("ITEM.functions.combine: not ply or not item or not other") return end
		
		item:InsertBattery(ply, other)
		
		local tblSoundParams = (item.sound and istable(item.sound["combine"]) and item.sound["combine"]) or {item.sound and item.sound["combine"] or "buttons/lightswitch2.wav", 75, 70, 1.0}
		ply:EmitSound(unpack(tblSoundParams))

		return false
	end,
	OnCanRun = function(item, data)
		local other = ix.item.instances[data[1]]
		
		return item:CanInsertBattery(item:GetOwner(), other)
	end
}

function ITEM:CanInsertBattery(ply, item)
	if not ply or not item then return end
	
	local bCanInsertBattery = ((istable(self.batteryItem) and self.batteryItem[item.uniqueID]) or item.uniqueID == self.batteryItem) and (item.CanPlayerInsertBattery and item:CanPlayerInsertBattery() or true) and self:GetEmptyBatterySlot()
	return bCanInsertBattery
end

function ITEM:GetEmptyBatterySlot()
	for i = 1, (self.maxBatteries or 1) do
		local key = "battery_" .. tostring(i)
		
		if not self:GetData(key) then
			return key
			-- self:SetData(key, item:GetID())
			-- item:Transfer(nil, nil, nil, ply, false, true)
			-- return true
		end
	end
end

function ITEM:InsertBattery(ply, item)
	-- local bCanInsertBattery = ((istable(self.batteryItem) and self.batteryItem[item.uniqueID]) or item.uniqueID == self.batteryItem) and (item.CanPlayerInsertBattery and item:CanPlayerInsertBattery() or true)
	-- if not bCanInsertBattery then return false end
	
	if not ply or not item then print("ITEM:InsertBattery: not ply or not item") return end
	
	local key = self:GetEmptyBatterySlot()
	
	print("ITEM:InsertBattery: key = " .. tostring(key))
	
	if key then
		self:SetData(key, item:GetID())
		item:Transfer(nil, nil, nil, ply, false, true)
		return true
	end
	
	return false
end

ITEM:Hook("OnRemoved", "RemoveEquipmentTimers", function(item, data)
	item:RemoveTimers()
	
	for i = 1, (item.maxBatteries or 1) do
		local key = "battery_" .. tostring(i)
		local batItemID = item:GetData(key)
		
		if batItemID then
			local batItem = ix.item.instances[batItemID]
			batItem:Remove()
		end
	end 
end)

-- Inventory drawing
if (CLIENT) then
	function ITEM:PaintOver(item, w, h)
		if (item:GetData("isOn")) then
			surface.SetDrawColor(110, 255, 110, 100)
			surface.DrawRect(w - 14, h - 14, 8, 8)
		end
	end

	function ITEM:PopulateTooltip(tooltip)
		if (self:GetData("isOn")) then
			local name = tooltip:GetRow("name")
			name:SetBackgroundColor(derma.GetColor("Success", tooltip))
		end
		
		if self.bPowerSupply then	
			local charge = tooltip:AddRow("charge")
			charge:SetText("Charge: " .. self.charge .. "%")
			charge:SetBackgroundColor(Color(50, 200, 50))
			charge:SizeToContents()	
		end
	end
end