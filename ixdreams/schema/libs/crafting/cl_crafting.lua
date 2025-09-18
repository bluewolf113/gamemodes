local Schema = Schema

if CLIENT then

	function ix.crafting.GetCraftingPanel()
		return ix.gui.invCrafting
	end

	function ix.crafting.DoCraftingAttempt(inventory, workstation, inputInvX, inputInvY, outputInvX, outputInvY, inputW, inputH, outputW, outputH)
		if inventory then
			local bHasItems = false
			local availableRecipes = ix.crafting.GetAvailableRecipes(inventory, workstation)
			
			for uniqueID, itemIDs in pairs(availableRecipes or {}) do
				local recipeTable = ix.crafting.GetRecipeTable(uniqueID)
				local inputItems = recipeTable.inputs
				
				bHasItems = ix.crafting.GetInputItemIDs(inventory:GetID(), inputItems, inputInvX, inputInvY, inputW, inputH)

				if bHasItems then 
					net.Start("ixDoCraftingAttempt")
						net.WriteString(uniqueID)
						net.WriteString(workstation or "none")
						net.WriteInt(inputInvX, 8)
						net.WriteInt(inputInvY, 8)
						net.WriteInt(outputInvX, 8)
						net.WriteInt(outputInvY, 8)
						net.WriteInt(inputW, 8)
						net.WriteInt(inputH, 8)
						net.WriteInt(outputW, 8)
						net.WriteInt(outputH, 8)
					net.SendToServer()
					break 
				end
			end
		end
	end

	net.Receive("ixInventorySet", function()
			local invID = net.ReadUInt(32)
			local x, y = net.ReadUInt(6), net.ReadUInt(6)
			local uniqueID = net.ReadString()
			local id = net.ReadUInt(32)
			local owner = net.ReadUInt(32)
			local data = net.ReadTable()

			local character = owner != 0 and ix.char.loaded[owner] or LocalPlayer():GetCharacter()

			if (character) then
				print("ixInventorySet: character = true")
				local inventory = ix.item.inventories[invID]

				if (inventory) then
					print("ixInventorySet: inventory = true")
					local item = (uniqueID != "" and id != 0) and ix.item.New(uniqueID, id) or nil
					item.invID = invID
					item.data = {}

					if (data) then
						item.data = data
					end

					inventory.slots[x] = inventory.slots[x] or {}
					inventory.slots[x][y] = item

					invID = invID == LocalPlayer():GetCharacter():GetInventory():GetID() and 1 or invID
					
					local invW, invH = inventory:GetSize()
					
					print("ixInventorySet: uniqueID = " .. tostring(uniqueID))

					local bCraftingPanelExists = ix.gui.invCrafting ~= nil
					local craftingPanels = ix.crafting.GetCraftingPanel()
					local panel = IsValid(craftingPanels) and craftingPanels:GetActiveGrid(x, y) or ix.gui["inv" .. invID]
					
					-- print("ixInventorySet: panel == craftingPanels.outPanel = " .. tostring(panel == craftingPanels.outPanel))
					
					print("ixInventorySet: x = " .. tostring(x))

					if (IsValid(panel)) then
						print("ixInventorySet: panel = valid")
						local icon = panel:AddIcon(
							item:GetModel() or "models/props_junk/popcan01a.mdl", x, y, item.width, item.height, item:GetSkin(), item:GetMaterial(), item:GetSubMaterial(), item:GetBodygroups(), item.bRotateIcon
						)
						
						print("ixInventorySet: (IsValid(icon)) = " .. tostring((IsValid(icon))))

						if (IsValid(icon)) then
							
							icon:SetHelixTooltip(function(tooltip)
								ix.hud.PopulateItemTooltip(tooltip, item)
							end)

							icon.itemID = item.id
							panel.panels[item.id] = icon
						end
					end
				end
			end
		end)
		
	net.Receive("ixInventoryRemove", function()
			local id = net.ReadUInt(32)
			local invID = net.ReadUInt(32)

			local inventory = ix.item.inventories[invID]

			if (!inventory) then
				return
			end

			inventory:Remove(id)

			invID = invID == LocalPlayer():GetCharacter():GetInventory():GetID() and 1 or invID
			local panel = ix.gui["inv" .. invID]
			local craftingPanels = (ix.gui.invCrafting and ix.gui.invCrafting.GetInvPanels and ix.gui.invCrafting:GetInvPanels()) or {}

			if (IsValid(panel)) then
				local icon = panel.panels[id]

				if (IsValid(icon)) then
					for _, v in ipairs(icon.slots or {}) do
						if (v.item == icon) then
							v.item = nil
						end
					end

					icon:Remove()
				end
			end
			
			for _, v in pairs(craftingPanels) do
				if (IsValid(v)) then
				local icon = v.panels[id]

				if (IsValid(icon)) then
					for _, v2 in ipairs(icon.slots or {}) do
						if (v2.item == icon) then
							v2.item = nil
						end
					end

					icon:Remove()
				end
			end
			end
			
			local item = ix.item.instances[id]

			if (!item) then
				return
			end

			-- we need to close any bag windows that are open because of this item
			if (item.isBag) then
				local itemInv = item:GetInventory()

				if (itemInv) then
					local frame = ix.gui["inv" .. itemInv:GetID()]

					if (IsValid(frame)) then
						frame:Remove()
					end
				end
			end
		end)
end