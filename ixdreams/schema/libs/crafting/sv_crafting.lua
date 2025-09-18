local Schema = Schema

util.AddNetworkString("ixDoCraftingAttempt")

function ix.crafting.ConsumeItems(inventory, uniqueID, targetIDs)
	local recipeTable = ix.crafting.GetRecipeTable(uniqueID)
	local inputs = recipeTable.inputs
	for _, id in pairs(targetIDs) do
		local item = ix.item.instances[id]
		local bNoDelete = inputs[item] and inputs[item].bNoDelete
		
		if not bNoDelete then
			item:Remove()
		end
	end
end

-- receive x and y from ixCrafting panel
function ix.crafting.SpawnOutputItems(inventory, items, outputX, outputY, outputW, outputH)
	print("SpawnOutputItems(): outputX = " .. tostring(outputX) .. ", outputY = " .. tostring(outputY))
	print("SpawnOutputItems(): outputW = " .. tostring(outputW) .. ", outputH = " .. tostring(outputH))
	local itemsLeft = table.Copy(items)
	for uniqueID, quantity in pairs(itemsLeft) do
		local itemTable = ix.item.list[uniqueID]
		local itemW = itemTable.width
		local itemH = itemTable.height
		
		print("SpawnOutputItems(): items = " .. tostring(items))
		
		if istable(quantity) then
			local iRangeMin = quantity[1]
			local iRangeMax = quantity[2] or iRangeMin
			iItemQuantity = math.ceil(math.random(iRangeMin - 0.99, iRangeMax))
		else
			iItemQuantity = quantity
		end
		
		itemsLeft[uniqueID] = iItemQuantity
		
		print("SpawnOutputItems(): iItemQuantity = " .. tostring(iItemQuantity))
		
		for i = 1, iItemQuantity do
			local emptyX, emptyY = inventory:FindEmptySlot(itemW, itemH, true, outputX, outputY, outputX + outputW, outputY + outputH)
			
			print("SpawnOutputItems(): emptyX = " .. tostring(emptyX) .. ", emptyY = " .. tostring(emptyY))
			
			if emptyX and emptyY then
				print("emptyX and emptyY exist")
				inventory:Add(uniqueID, 1, {}, emptyX, emptyY)
				if itemsLeft[uniqueID] > 0 then
					itemsLeft[uniqueID] = itemsLeft[uniqueID] - 1
				end
			else
				print("SpawnOutputItems(): SpawnItemsOnPlayer")
				Schema:SpawnItemsOnPlayer(inventory:GetOwner(), {[uniqueID] = itemsLeft[uniqueID]})
				break
			end
		end
	end
end

net.Receive("ixDoCraftingAttempt", function(len, ply)
	local uniqueID = net.ReadString()
	local workstation = net.ReadString()
	
	local inputX = net.ReadInt(8)
	local inputY = net.ReadInt(8)
	local outputX = net.ReadInt(8)
	local outputY = net.ReadInt(8)
	
	local inputW = net.ReadInt(8)
	local inputH = net.ReadInt(8)
	local outputW = net.ReadInt(8)
	local outputH = net.ReadInt(8)

	if not ply or not ply:GetCharacter() then return end
	
	local inventory = ply:GetCharacter():GetInventory()
	
	if not inventory then return end

	local targetIDs = ix.crafting.GetInputItemIDs(inventory:GetID(), ix.crafting.GetRecipeTable(uniqueID).inputs, inputX, inputY, inputW, inputH)
	
	if targetIDs then
		local outputItems = ix.crafting.GetRecipeTable(uniqueID).outputs
		
		ix.crafting.ConsumeItems(inventory, uniqueID, targetIDs)
		ix.crafting.SpawnOutputItems(inventory, outputItems, outputX, outputY, outputW, outputH)
	end
end)

net.Receive("ixInventoryMove", function(length, client)
		local oldX, oldY, x, y = net.ReadUInt(6), net.ReadUInt(6), net.ReadUInt(6), net.ReadUInt(6)
		local invID, newInvID = net.ReadUInt(32), net.ReadUInt(32)
		
		local bOverrideFitItem = net.ReadBool() or false

		local character = client:GetCharacter()

		if (character) then
			local inventory = ix.item.inventories[invID]

			if (!inventory or inventory == nil) then
				inventory:Sync(client)
			end

			if ((inventory.owner and inventory.owner == character:GetID()) or inventory:OnCheckAccess(client)) then
				local item = inventory:GetItemAt(oldX, oldY)

				if (item) then
					if (newInvID and invID != newInvID) then
						local inventory2 = ix.item.inventories[newInvID]

						if (inventory2) then
							local bStatus, error = item:Transfer(newInvID, x, y, client)

							if (!bStatus) then
								NetworkInventoryMove(
									client, item.invID, item:GetID(), item.gridX, item.gridY, item.gridX, item.gridY
								)

								client:NotifyLocalized(error or "unknownError")
							end
						end

						return
					end

					if (inventory:CanItemFit(x, y, item.width, item.height, item, bOverrideFitItem)) then
						item.gridX = x
						item.gridY = y

						for x2 = 0, item.width - 1 do
							for y2 = 0, item.height - 1 do
								local previousX = inventory.slots[oldX + x2]

								if (previousX) then
									previousX[oldY + y2] = nil
								end
							end
						end

						for x2 = 0, item.width - 1 do
							for y2 = 0, item.height - 1 do
								inventory.slots[x + x2] = inventory.slots[x + x2] or {}
								inventory.slots[x + x2][y + y2] = item
							end
						end

						local receivers = inventory:GetReceivers()

						if (istable(receivers)) then
							local filtered = {}

							for _, v in ipairs(receivers) do
								if (v != client) then
									filtered[#filtered + 1] = v
								end
							end

							if (#filtered > 0) then
								NetworkInventoryMove(
									filtered, invID, item:GetID(), oldX, oldY, x, y
								)
							end
						end

						if (!inventory.noSave) then
							local query = mysql:Update("ix_items")
								query:Update("x", x)
								query:Update("y", y)
								query:Where("item_id", item.id)
							query:Execute()
						end
					else
						NetworkInventoryMove(
							client, item.invID, item:GetID(), item.gridX, item.gridY, item.gridX, item.gridY
						)
					end
				end
			else
				local item = inventory:GetItemAt(oldX, oldY)

				if (item) then
					NetworkInventoryMove(
						client, item.invID, item.invID, item:GetID(), item.gridX, item.gridY, item.gridX, item.gridY
					)
				end
			end
		end
	end)