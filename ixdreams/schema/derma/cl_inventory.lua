
local RECEIVER_NAME = "ixInventoryItem"

-- The queue for the rendered icons.
ICON_RENDER_QUEUE = ICON_RENDER_QUEUE or {}

local animationTime = 0.8 * ix.config.Get("animationScale", 1)

-- To make making inventory variant, This must be followed up.
local function RenderNewIcon(panel, itemTable)
	-- local model = itemTable:GetModel()
	-- local skin = itemTable:GetSkin()
	-- local material = itemTable:GetMaterial()
	-- panel.Icon:SetModel(model, skin, material)

	-- -- re-render icons
	-- if ((itemTable.iconCam and !ICON_RENDER_QUEUE[string.lower(model)]) or itemTable.forceRender) then
		-- local iconCam = itemTable.iconCam
		-- iconCam = {
			-- cam_pos = iconCam.pos,
			-- cam_ang = iconCam.ang,
			-- cam_fov = iconCam.fov,
		-- }
		-- ICON_RENDER_QUEUE[string.lower(model)] = true

		-- panel.Icon:SetModel(model, skin, material)
	-- end
end

local function InventoryAction(action, itemID, invID, data)
	net.Start("ixInventoryAction")
		net.WriteString(action)
		net.WriteUInt(itemID, 32)
		net.WriteUInt(invID, 32)
		net.WriteTable(data or {})
	net.SendToServer()
end

local PANEL = {}

AccessorFunc(PANEL, "itemTable", "ItemTable")
AccessorFunc(PANEL, "inventoryID", "InventoryID")

function PANEL:Init()
	self:Droppable(RECEIVER_NAME)
	
	self.Icon = self:Add("ixItemModelPanel")
	self.Icon:Dock(1)
end

function PANEL:OnMousePressed(code)
	if (code == MOUSE_LEFT and self:IsDraggable()) then
		self:MouseCapture(true)
		self:DragMousePress(code)

		self.clickX, self.clickY = input.GetCursorPos()
	elseif (code == MOUSE_RIGHT and self.DoRightClick) then
		self:DoRightClick()
	end
end

function PANEL:OnMouseReleased(code)
	-- move the item into the world if we're dropping on something that doesn't handle inventory item drops
	if (!dragndrop.m_ReceiverSlot or dragndrop.m_ReceiverSlot.Name != RECEIVER_NAME) then
		self:OnDrop(dragndrop.IsDragging())
	end

	self:DragMouseRelease(code)
	self:SetZPos(99)
	self:MouseCapture(false)
end

function PANEL:DoRightClick()
	local itemTable = self.itemTable
	local inventory = self.inventoryID

	if (itemTable and inventory) then
		itemTable.player = LocalPlayer()

		local menu = DermaMenu()
		local override = hook.Run("CreateItemInteractionMenu", self, menu, itemTable)

		if (override == true) then
			if (menu.Remove) then
				menu:Remove()
			end

			return
		end

		for k, v in SortedPairs(itemTable.functions) do
			if (k == "drop" or k == "combine" or (v.OnCanRun and v.OnCanRun(itemTable) == false)) then
				continue
			end

			-- is Multi-Option Function
			if (v.isMulti) then
				local subMenu, subMenuOption = menu:AddSubMenu(L(v.name or k), function()
					itemTable.player = LocalPlayer()
						local send = true

						if (v.OnClick) then
							send = v.OnClick(itemTable)
						end

						if (v.sound) then
							surface.PlaySound(v.sound)
						end

						if (send != false) then
							InventoryAction(k, itemTable.id, inventory)
						end
					itemTable.player = nil
				end)
				subMenuOption:SetImage(v.icon or "icon16/brick.png")

				if (v.multiOptions) then
					local options = isfunction(v.multiOptions) and v.multiOptions(itemTable, LocalPlayer()) or v.multiOptions

					for _, sub in pairs(options) do
						subMenu:AddOption(L(sub.name or "subOption"), function()
							itemTable.player = LocalPlayer()
								local send = true

								if (sub.OnClick) then
									send = sub.OnClick(itemTable)
								end

								if (sub.sound) then
									surface.PlaySound(sub.sound)
								end

								if (send != false) then
									InventoryAction(k, itemTable.id, inventory, sub.data)
								end
							itemTable.player = nil
						end)
					end
				end
			else
				menu:AddOption(L(v.name or k), function()
					itemTable.player = LocalPlayer()
						local send = true

						if (v.OnClick) then
							send = v.OnClick(itemTable)
						end

						if (v.sound) then
							surface.PlaySound(v.sound)
						end

						if (send != false) then
							InventoryAction(k, itemTable.id, inventory)
						end
					itemTable.player = nil
				end):SetImage(v.icon or "icon16/brick.png")
			end
		end

		-- we want drop to show up as the last option
		local info = itemTable.functions.drop

		if (info and info.OnCanRun and info.OnCanRun(itemTable) != false) then
			menu:AddOption(L(info.name or "drop"), function()
				itemTable.player = LocalPlayer()
					local send = true

					if (info.OnClick) then
						send = info.OnClick(itemTable)
					end

					if (info.sound) then
						surface.PlaySound(info.sound)
					end

					if (send != false) then
						InventoryAction("drop", itemTable.id, inventory)
					end
				itemTable.player = nil
			end):SetImage(info.icon or "icon16/brick.png")
		end

		menu:Open()
		itemTable.player = nil
	end
end

function PANEL:OnDrop(bDragging, inventoryPanel, inventory, gridX, gridY)
	local item = self.itemTable

	if (!item or !bDragging) then
		return
	end

	if (!IsValid(inventoryPanel)) then
		local inventoryID = self.inventoryID

		if (inventoryID) then
			InventoryAction("drop", item.id, inventoryID, {})
		end
	elseif (inventoryPanel:IsAllEmpty(gridX, gridY, item.width, item.height, self)) then
		local oldX, oldY = self.gridX, self.gridY
		
		local offsetX = inventoryPanel:GetOffsetX() or 0
		local offsetY = inventoryPanel:GetOffsetY() or 0
		
		if ((not inventoryPanel.noDrop) and (oldX != (gridX + offsetX) or oldY != (gridY + offsetY) or self.inventoryID != inventoryPanel.invID)) then
			self:Move(gridX, gridY, inventoryPanel, false)
		end
	elseif (inventoryPanel.combineItem) then
		local combineItem = inventoryPanel.combineItem
		local inventoryID = combineItem.invID

		if (inventoryID) then
			combineItem.player = LocalPlayer()
				if (combineItem.functions.combine.sound) then
					surface.PlaySound(combineItem.functions.combine.sound)
				end

				InventoryAction("combine", combineItem.id, inventoryID, {item.id})
			combineItem.player = nil
		end
	end
end

function PANEL:Move(newX, newY, givenInventory, bNoSend)
	local iconSize = givenInventory.iconSize
	local oldX, oldY = self.gridX, self.gridY
	local oldParent = self:GetParent()
	local item = self.itemTable

	if (givenInventory:OnTransfer(oldX, oldY, newX, newY, oldParent, bNoSend) == false) then
		return
	end

	local x = (newX - 1) * iconSize + 4
	local y = (newY - 1) * iconSize + givenInventory:GetPadding(2)

	self:SetParent(givenInventory)
	self:SetPos(x, y)

	if (self.slots) then
		for _, v in ipairs(self.slots) do
			if (IsValid(v) and v.item == self) then
				v.item = nil
			end
		end
	end

	self.slots = {}
	
	local offsetX = givenInventory:GetOffsetX() or 0
	local offsetY = givenInventory:GetOffsetY() or 0
	
	self.gridX = newX + offsetX
	self.gridY = newY + offsetY

	for currentX = 1, self.gridW do
		for currentY = 1, self.gridH do
			local slotX = self.gridX + currentX - 1
			local slotY = self.gridY + currentY - 1
			
			local adjustedX = slotX + offsetX
			local adjustedY = slotY + offsetY

			local slot = givenInventory.slots[slotX][slotY]

			slot.item = self
			self.slots[#self.slots + 1] = slot
		end
	end
end

function PANEL:PaintOver(width, height)
	local itemTable = self.itemTable

	if (itemTable and itemTable.PaintOver) then
		itemTable.PaintOver(self, itemTable, width, height)
	end
end

function PANEL:ExtraPaint(width, height)
end

function PANEL:Paint(width, height)
	surface.SetDrawColor(0, 0, 0, 85)
	surface.DrawRect(2, 2, width - 4, height - 4)

	self:ExtraPaint(width, height)
end

vgui.Register("ixItemIcon", PANEL)

local PANEL = {}

-- AccessorFunc(PANEL, "itemTable", "ItemTable")
-- AccessorFunc(PANEL, "inventoryID", "InventoryID")

function PANEL:Init()
	self:SetMouseInputEnabled(false)
	
	-- RegisterDermaMenuForClose(self)
end

-- function PANEL:GetDeleteSelf()
	-- return true
-- end

function PANEL:FadeIn(bOverrideNoAnim)

	local bNoAnim = ix.option.Get("disableAnimations") and not bOverrideNoAnim
	
	if not bNoAnim then	
		self:SetAlpha(0) 
		self:AlphaTo(255, animationTime, 0, function() end)	
	end
end

function PANEL:FadeOut()
	local bNoAnim = ix.option.Get("disableAnimations")
	
	if not bNoAnim then
		if self:GetAlpha() == 255 then
			self:AlphaTo(0, animationTime * 0.3, 0, function() end)
		else
			self:Stop()
			self:AlphaTo(0, animationTime * 0.1, 0, function() end)
		end
	end
end

function PANEL:Remove()
	
	self:FadeOut()
	
	-- self:AlphaTo(0, animationTime * 0.3, 0, function() end)
end

function PANEL:SetModel(model, skin, material, submaterials, bodygroups, rotation)
	if (IsValid(self.Entity)) then
		self.Entity:Remove()
		self.Entity = nil
	end

	if (!ClientsideModel) then
		return
	end

	local entity = ClientsideModel(model, RENDERGROUP_OPAQUE)

	if (!IsValid(entity)) then
		return
	end

	entity:SetNoDraw(true)
	-- entity:SetIK(false)

	if (skin) then
		entity:SetSkin(skin)
	end
	
	if (material) then
		entity:SetMaterial(material)
	end
	
	if istable(submaterials) then
		for k, v in pairs(submaterials) do
			entity:SetSubMaterial(k, v)
		end
	end
	
	if (bodygroups) then
		for bodygroupID, submodelID in pairs(bodygroups) do
			local bgID = isnumber(bodygroupID) and bodygroupID or isstring(bodygroupID) and entity:FindBodygroupByName(bodygroupID)
			entity:SetBodygroup(bgID, submodelID)
		end	
	end
	
	if not rotation then
		local function layoutEntity() end
		
		self.LayoutEntity = layoutEntity
	end

	-- local sequence = entity:LookupSequence("idle_unarmed")

	-- if (sequence <= 0) then
		-- sequence = entity:SelectWeightedSequence(ACT_IDLE)
	-- end

	-- if (sequence > 0) then
		-- entity:ResetSequence(sequence)
	-- else
		-- local found = false

		-- for _, v in ipairs(entity:GetSequenceList()) do
			-- if ((v:lower():find("idle") or v:lower():find("fly")) and v != "idlenoise") then
				-- entity:ResetSequence(v)
				-- found = true

				-- break
			-- end
		-- end

		-- if (!found) then
			-- entity:ResetSequence(4)
		-- end
	-- end

	self.Entity = entity
	
	if self.Entity then
		local camData = PositionSpawnIcon(self.Entity, self.Entity:GetPos())
		
		self:SetCamPos(camData.origin)
		self:SetLookAng(camData.angles)
		self:SetFOV(camData.fov)
	end
end

-- New functions

-- function PANEL:LayoutEntity()
	-- local entity = self.Entity

	-- entity:SetAngles(MODEL_ANGLE)
	-- entity:SetIK(false)

	-- self:RunAnimation()
-- end

function PANEL:DrawModel()
	-- local brightness = self.brightness * 0.4
	-- local brightness2 = self.brightness * 1.5

	-- render.SetStencilEnable(false)
	-- render.SetColorMaterial()
	-- render.SetColorModulation(1, 1, 1)
	-- render.SetModelLighting(0, brightness2, brightness2, brightness2)

	-- for i = 1, 4 do
		-- render.SetModelLighting(i, brightness, brightness, brightness)
	-- end

	-- local fraction = (brightness / 1) * 0.1

	-- render.SetModelLighting(5, fraction, fraction, fraction)

	-- Excecute Some stuffs
	if (self.enableHook) then
		hook.Run("DrawHelixModelView", self, self.Entity)
	end
	
	self.Entity:DrawModel()

end

vgui.Register("ixItemModelPanel", PANEL, "DModelPanel")

PANEL = {}
DEFINE_BASECLASS("DFrame")

AccessorFunc(PANEL, "iconSize", "IconSize", FORCE_NUMBER)
AccessorFunc(PANEL, "bHighlighted", "Highlighted", FORCE_BOOL)

function PANEL:Init()
	self:SetIconSize(64)
	self:ShowCloseButton(false)
	self:SetDraggable(true)
	self:SetSizable(true)
	self:SetTitle(L"inv")
	self:Receiver(RECEIVER_NAME, self.ReceiveDrop)

	self.btnMinim:SetVisible(false)
	self.btnMinim:SetMouseInputEnabled(false)
	self.btnMaxim:SetVisible(false)
	self.btnMaxim:SetMouseInputEnabled(false)

	self.panels = {}
end

function PANEL:GetPadding(index)
	return select(index, self:GetDockPadding())
end

function PANEL:SetTitle(text)
	if (text == nil) then
		self.oldPadding = {self:GetDockPadding()}

		self.lblTitle:SetText("")
		self.lblTitle:SetVisible(false)

		self:DockPadding(5, 5, 5, 5)
	else
		if (self.oldPadding) then
			self:DockPadding(unpack(self.oldPadding))
			self.oldPadding = nil
		end

		BaseClass.SetTitle(self, text)
	end
end

function PANEL:FitParent(invWidth, invHeight)
	local parent = self:GetParent()

	if (!IsValid(parent)) then
		return
	end

	local width, height = parent:GetSize()
	local padding = 4
	local iconSize

	if (invWidth > invHeight) then
		iconSize = (width - padding * 2) / invWidth
	elseif (invHeight > invWidth) then
		iconSize = (height - padding * 2) / invHeight
	else
		-- we use height because the titlebar will make it more tall than it is wide
		iconSize = (height - padding * 2) / invHeight - 4
	end

	self:SetSize(iconSize * invWidth + padding * 2, iconSize * invHeight + padding * 2)
	self:SetIconSize(iconSize)
end

function PANEL:DropExtraItems()
	if self.bDumpItems then
		for id, icon in pairs(self.panels) do
			local inventory = LocalPlayer():GetCharacter():GetInventory()
			local itemTable = ix.item.instances[id]
			
			local invX, invY = inventory:FindEmptySlot(itemTable.width, itemTable.height)

			if invX and invY then
				print("invX = " .. tostring(invX) .. ", invY = " .. tostring(invY))
				print("attempting move")
				self:OnTransfer(icon.gridX, icon.gridY, invX, invY, self, false)
				-- net.Start("ixInventoryMove")
					-- net.WriteUInt(icon.gridX, 6)
					-- net.WriteUInt(icon.gridY, 6)
					-- net.WriteUInt(invX, 6)
					-- net.WriteUInt(invY, 6)
					-- net.WriteUInt(self.invID, 32)
					-- net.WriteUInt(self.invID, 32)
					-- net.WriteBool(false)
				-- net.SendToServer()			
			else	
				print("attempting drop")
				InventoryAction("drop", id, self.invID, {})

				if inventory and inventory.slots and inventory.slots[icon.gridX] then
					inventory.slots[icon.gridX][icon.gridY] = nil
				end
			end
		end
	end
end

function PANEL:OnRemove()
	if (self.childPanels) then
		for _, v in ipairs(self.childPanels) do
			if (v != self) then
				v:Remove()
			end
		end
	end
	
	self:DropExtraItems()
end

function PANEL:ViewOnly()
	self.viewOnly = true

	for _, icon in pairs(self.panels) do
		icon.OnMousePressed = nil
		icon.OnMouseReleased = nil
		icon.doRightClick = nil
	end
end

function PANEL:SetInventory(inventory, bFitParent)
	if (inventory.slots) then
		local invWidth, invHeight = inventory:GetSize()
		self.invID = inventory:GetID()

		if (IsValid(ix.gui.inv1) and ix.gui.inv1.childPanels and inventory != LocalPlayer():GetCharacter():GetInventory()) then
			self:SetIconSize(ix.gui.inv1:GetIconSize())
			self:SetPaintedManually(true)
			self.bNoBackgroundBlur = true

			ix.gui.inv1.childPanels[#ix.gui.inv1.childPanels + 1] = self
		elseif (bFitParent) then
			self:FitParent(invWidth, invHeight)
		else
			self:SetSize(self.iconSize, self.iconSize)
		end
		
		local offsetX = self.offsetX or 0
		local offsetY = self.offsetY or 0
		
		local w = self.gridW or invWidth
		local h = self.gridH or invHeight

		self:SetGridSize(w, h)
		
		for id, icon in pairs(self.panels) do
			if IsValid(icon) then
				icon:Remove()
			end
		end

		for x, items in pairs(inventory.slots) do
			for y, data in pairs(items) do
				if (!data.id) or (x < offsetX or y < offsetY) or (x - offsetX > self.gridW or y - offsetY > self.gridH) then continue end

				local item = ix.item.instances[data.id]
				
				local material = item:GetMaterial()

				if (item and !IsValid(self.panels[item.id])) then
					local icon = self:AddIcon(item:GetModel() or "models/props_junk/popcan01a.mdl",
						x - offsetX, y - offsetY, item.width, item.height, item:GetSkin(), item:GetMaterial(), item:GetSubMaterial(), item:GetBodygroups(), item.bRotateIcon)

					if (IsValid(icon)) then
						icon.Icon:FadeIn()
						icon:SetHelixTooltip(function(tooltip)
							ix.hud.PopulateItemTooltip(tooltip, item)
						end)

						self.panels[item.id] = icon
					end
				end
			end
		end
	end
end

function PANEL:SetGridSize(w, h, bNoBuildSlots)
	local iconSize = self.iconSize
	local newWidth = w * iconSize + 8
	local newHeight = h * iconSize + self:GetPadding(2) + self:GetPadding(4)

	self.gridW = w
	self.gridH = h

	self:SetSize(newWidth, newHeight)
	self:SetMinWidth(newWidth)
	self:SetMinHeight(newHeight)
	if not bNoBuildSlots then self:BuildSlots() end
end

function PANEL:GetGridSize()
	return self.gridW, self.gridH
end

function PANEL:PerformLayout(width, height)
	BaseClass.PerformLayout(self, width, height)

	if (self.Sizing and self.gridW and self.gridH) then
		local newWidth = (width - 8) / self.gridW
		local newHeight = (height - self:GetPadding(2) + self:GetPadding(4)) / self.gridH

		self:SetIconSize((newWidth + newHeight) / 2)
		self:RebuildItems()
	end
end

function PANEL:BuildSlots()
	local iconSize = self.iconSize

	self.slots = self.slots or {}

	for _, v in ipairs(self.slots) do
		for _, v2 in ipairs(v) do
			v2:Remove()
		end
	end

	self.slots = {}	
	
	local offsetX = self.offsetX or 0
	local offsetY = self.offsetY or 0

	for x = 1, self.gridW do
		local adjustedX = x + offsetX
		self.slots[adjustedX] = {}

		for y = 1, self.gridH do
			local adjustedY = y + offsetY
			local slot = self:Add("DPanel")
			slot:SetZPos(-999)
			slot.gridX = adjustedX
			slot.gridY = adjustedY

			slot:SetPos((x - 1) * iconSize + 4, (y - 1) * iconSize + self:GetPadding(2))
			slot:SetSize(iconSize, iconSize)
			slot.Paint = function(panel, width, height)
				derma.SkinFunc("PaintInventorySlot", panel, width, height)
			end

			self.slots[adjustedX][adjustedY] = slot
			
			if self.offsetX and self.offsetX > 0 then

				-- print("PANEL:BuildSlots: offsetX = " .. tostring(offsetX) .. ", offsetY = " .. tostring(offsetY))
				-- print("PANEL:BuildSlots: adjustedX = " .. tostring(adjustedX) .. ", adjustedY = " .. tostring(adjustedY))
				-- print("PANEL:BuildSlots: self.slots[adjustedX][adjustedY] = " .. tostring(self.slots[adjustedX][adjustedY]))
				
				-- for k, v in pairs(self.slots) do
					-- print("PANEL:BuildSlots: k = " .. tostring(k) .. ", v = " .. tostring(v))
				-- end
			end
		end
	end
end

function PANEL:RebuildItems()
	local iconSize = self.iconSize
	
	local offsetX = self.offsetX or 0
	local offsetY = self.offsetY or 0

	for x = 1, self.gridW do
		local adjustedX = x + offsetX
		for y = 1, self.gridH do
			local adjustedY = y + offsetY
			local slot = self.slots[adjustedX][adjustedY]

			slot:SetPos((x - 1) * iconSize + 4, (y - 1) * iconSize + self:GetPadding(2))
			slot:SetSize(iconSize, iconSize)
		end
	end

	for _, v in pairs(self.panels) do
		if (IsValid(v)) then
		
			local offsetX = self.offsetX or 0
			local offsetY = self.offsetY or 0
			
			local adjustedX = v.gridX + offsetX
			local adjustedY = v.gridY + offsetY
			
			v:SetPos(self.slots[adjustedX][adjustedY]:GetPos())
			v:SetSize(v.gridW * iconSize, v.gridH * iconSize)
		end
	end
end

function PANEL:RefreshIcons()
	local inventory = ix.item.inventories[self.invID]
	
	for id, icon in pairs(self.panels) do
		if not inventory:GetItemsByID(id) then
			icon:Remove()
		end
	end
end

function PANEL:PaintDragPreview(width, height, mouseX, mouseY, itemPanel)
	local iconSize = self.iconSize
	local item = itemPanel:GetItemTable()

	if (item) then
		local inventory = ix.item.inventories[self.invID]
		local dropX = math.ceil((mouseX - 4 - (itemPanel.gridW - 1) * 32) / iconSize)
		local dropY = math.ceil((mouseY - self:GetPadding(2) - (itemPanel.gridH - 1) * 32) / iconSize)

		local hoveredPanel = vgui.GetHoveredPanel()

		if (IsValid(hoveredPanel) and hoveredPanel != itemPanel and hoveredPanel.GetItemTable) then
			local hoveredItem = hoveredPanel:GetItemTable()

			if (hoveredItem) then
				local info = hoveredItem.functions.combine

				if (info and (info.OnCanRun and info.OnCanRun(hoveredItem, {item.id}) != false)) then
					surface.SetDrawColor(ColorAlpha(derma.GetColor("Info", self, Color(200, 0, 0)), 20))
					surface.DrawRect(
						hoveredPanel.x,
						hoveredPanel.y,
						hoveredPanel:GetWide(),
						hoveredPanel:GetTall()
					)

					self.combineItem = hoveredItem

					return
				end
			end
		end

		self.combineItem = nil

		-- don't draw grid if we're dragging it out of bounds
		if (inventory) then
			local invWidth, invHeight = inventory:GetSize()

			if (dropX < 1 or dropY < 1 or
				dropX + itemPanel.gridW - 1 > invWidth or
				dropY + itemPanel.gridH - 1 > invHeight) then
				return
			end
		end

		local bEmpty = true

		for x = 0, itemPanel.gridW - 1 do
			for y = 0, itemPanel.gridH - 1 do
				local x2 = dropX + x
				local y2 = dropY + y

				bEmpty = self:IsEmpty(x2, y2, itemPanel) and (not self.noDrop)

				if (!bEmpty) then
					-- no need to iterate further since we know something is blocking the hovered grid cells, break through both loops
					goto finish
				end
			end
		end

		::finish::
		local previewColor = ColorAlpha(derma.GetColor(bEmpty and "Success" or "Error", self, Color(200, 0, 0)), 20)

		surface.SetDrawColor(previewColor)
		surface.DrawRect(
			(dropX - 1) * iconSize + 4,
			(dropY - 1) * iconSize + self:GetPadding(2),
			itemPanel:GetWide(),
			itemPanel:GetTall()
		)
	end
end

function PANEL:PaintOver(width, height)
	local panel = self.previewPanel

	if (IsValid(panel)) then
		local itemPanel = (dragndrop.GetDroppable() or {})[1]

		if (IsValid(itemPanel)) then
			self:PaintDragPreview(width, height, self.previewX, self.previewY, itemPanel)
		end
	end

	self.previewPanel = nil
end

function PANEL:SetNoDrop(bNoDrop)
	self.noDrop = bNoDrop
end

function PANEL:GetNoDrop()
	return self.noDrop
end

function PANEL:WhitelistItem(uniqueID, bRemoveFromWhitelist)
	self.whitelist = self.whitelist or {}
	self.whitelist[uniqueID] = not bRemoveFromWhitelist
end

function PANEL:IsItemWhitelisted(uniqueID)
	return self.whitelist[uniqueID]
end

function PANEL:IsEmpty(x, y, this)

	local offsetX = self.offsetX or 0
	local offsetY = self.offsetY or 0
	
	local adjustedX = x + offsetX
	local adjustedY = y + offsetY
	
	return (self.slots[adjustedX] and self.slots[adjustedX][adjustedY]) and (!IsValid(self.slots[adjustedX][adjustedY].item) or self.slots[adjustedX][adjustedY].item == this)
end

function PANEL:IsAllEmpty(x, y, width, height, this)
	for x2 = 0, width - 1 do
		for y2 = 0, height - 1 do
			if (!self:IsEmpty(x + x2, y + y2, this)) then
				return false
			end
		end
	end

	return true
end

function PANEL:OnTransfer(oldX, oldY, x, y, oldInventory, noSend)
	local inventories = ix.item.inventories
	local inventory = inventories[oldInventory.invID] or oldInventory
	local inventory2 = inventories[self.invID]
	local item
	
	local offsetX = self.offsetX or 0
	local offsetY = self.offsetY or 0
	
	local adjustedX = x + offsetX
	local adjustedY = y + offsetY

	if (inventory) then
		item = inventory:GetItemAt(oldX, oldY)

		if (!item) then
			return false
		end

		if (hook.Run("CanTransferItem", item, inventories[oldInventory.invID], inventories[self.invID]) == false) then
			return false, "notAllowed"
		end

		if (item.CanTransfer and
			item:CanTransfer(inventory, inventory != inventory2 and inventory2 or nil) == false) then
			return false
		end
	end

	if (!noSend) then
		net.Start("ixInventoryMove")
			net.WriteUInt(oldX, 6)
			net.WriteUInt(oldY, 6)
			net.WriteUInt(adjustedX, 6)
			net.WriteUInt(adjustedY, 6)
			net.WriteUInt(oldInventory.invID, 32)
			net.WriteUInt(self != oldInventory and self.invID or oldInventory.invID, 32)
			net.WriteBool((offsetX > 0 and offsetY > 0))
		net.SendToServer()
	end

	if (inventory) then
		inventory.slots[oldX][oldY] = nil
	end

	if (item and inventory2) then
		inventory2.slots[adjustedX] = inventory2.slots[adjustedX] or {}
		inventory2.slots[adjustedX][adjustedY] = item
	end
end

function PANEL:SetOffsets(offsetX, offsetY)
	self.offsetX = offsetX
	self.offsetY = offsetY
end

function PANEL:GetOffsets()
	return self.offsetX, self.offsetY
end

function PANEL:GetOffsetX()
	return self.offsetX
end

function PANEL:GetOffsetY()
	return self.offsetY
end

function PANEL:AddIcon(model, x, y, w, h, skin, material, submaterials, bodygroups, rotation, bNoFadeIn)
	local iconSize = self.iconSize
	
	w = w or 1
	h = h or 1
	
	local offsetX = self.offsetX or 0
	local offsetY = self.offsetY or 0
	
	local adjustedX = x + offsetX
	local adjustedY = y + offsetY
	
	if self.offsetX and self.offsetX > 0 then
	
	
		print("PANEL:AddIcon: x = " .. tostring(x) .. ", y = " .. tostring(y))
		print("PANEL:AddIcon: offsetX = " .. tostring(offsetX) .. ", offsetY = " .. tostring(offsetY))
		print("PANEL:AddIcon: adjustedX = " .. tostring(adjustedX) .. ", adjustedY = " .. tostring(adjustedY))
		print("PANEL:AddIcon: self.slots[adjustedX][adjustedY] = " .. tostring(self.slots[adjustedX] and self.slots[adjustedX][adjustedY] or nil))
		
		-- for k, v in pairs(self.slots) do
			-- print("PANEL:AddIcon: k = " .. tostring(k) .. ", v = " .. tostring(v))
		-- end
		
	end

	if (self.slots[adjustedX] and self.slots[adjustedX][adjustedY]) then
	
		local panel = self:Add("ixItemIcon")
		panel:SetSize(w * iconSize, h * iconSize)
		panel:SetZPos(999)
		panel:InvalidateLayout(true)
		panel.Icon:SetModel(model, skin, material, submaterials, bodygroups, rotation)
		panel:SetPos(self.slots[adjustedX][adjustedY]:GetPos())
		panel.gridX = adjustedX
		panel.gridY = adjustedY
		panel.gridW = w
		panel.gridH = h
		
		-- local testPanel = vgui.Create("ixItemModelPanel")
		-- testPanel:SetModel(model)
		-- testPanel:SetPos(self.slots[x][y]:GetPos())
		-- testPanel:SetWidth(80)
		-- testPanel:SetHeight(80)
		
		-- testPanel:DrawModel()

		local inventory = ix.item.inventories[self.invID]

		if (!inventory) then
			print("PANEL:AddIcon: !inventory")
			return
		end

		local itemTable = inventory:GetItemAt(panel.gridX, panel.gridY)

		panel:SetInventoryID(inventory:GetID())
		panel:SetItemTable(itemTable)

		if (self.panels[itemTable:GetID()]) then
			self.panels[itemTable:GetID()]:Remove()
		end

		-- if (itemTable.exRender) then
			-- panel.Icon:SetVisible(false)
			-- panel.ExtraPaint = function(this, panelX, panelY)
				-- local exIcon = ikon:GetIcon(itemTable.uniqueID)
				-- if (exIcon) then
					-- surface.SetMaterial(exIcon)
					-- surface.SetDrawColor(color_white)
					-- surface.DrawTexturedRect(0, 0, panelX, panelY)
				-- else
					-- ikon:renderIcon(
						-- itemTable.uniqueID,
						-- itemTable.width,
						-- itemTable.height,
						-- itemTable:GetModel(),
						-- itemTable.iconCam
					-- )
				-- end
			-- end
		-- else
			-- -- yeah..
			-- RenderNewIcon(panel, itemTable)
		-- end

		panel.slots = {}

		for i = 0, w - 1 do
			for i2 = 0, h - 1 do
				if not self.slots then self.slots = {} end
				
				local slot = self.slots[adjustedX + i] and self.slots[adjustedX + i][adjustedY + i2]

				if (IsValid(slot)) then
					slot.item = panel
					panel.slots[#panel.slots + 1] = slot
				else
					for _, v in ipairs(panel.slots) do
						v.item = nil
					end
					print("PANEL:AddIcon: panel:Remove() and return nil")
					panel:Remove()

					return
				end
			end
		end
		if self.offsetX and self.offsetX > 0 then
			print("PANEL:AddIcon: IsValid(panel) = " .. tostring(panel))		
		end
		
		return panel
	end
end

function PANEL:ReceiveDrop(panels, bDropped, menuIndex, x, y)
	local panel = panels[1]

	if (!IsValid(panel)) then
		self.previewPanel = nil
		return
	end

	if (bDropped) then
		local inventory = ix.item.inventories[self.invID]

		if (inventory and panel.OnDrop) then
			local dropX = math.ceil((x - 4 - (panel.gridW - 1) * 32) / self.iconSize)
			local dropY = math.ceil((y - self:GetPadding(2) - (panel.gridH - 1) * 32) / self.iconSize)

			panel:OnDrop(true, self, inventory, dropX, dropY)
		end

		self.previewPanel = nil
	else
		self.previewPanel = panel
		self.previewX = x
		self.previewY = y
	end
end

vgui.Register("ixInventory", PANEL, "DFrame")

hook.Add("CreateMenuButtons", "ixInventory", function(tabs)
	if (hook.Run("CanPlayerViewInventory") == false) then
		return
	end

	tabs["inv"] = {
		bDefault = true,
		Create = function(info, container)
			local canvas = container:Add("DTileLayout")
			local canvasLayout = canvas.PerformLayout
			canvas.PerformLayout = nil -- we'll layout after we add the panels instead of each time one is added
			canvas:SetBorder(0)
			canvas:SetSpaceX(2)
			canvas:SetSpaceY(2)
			canvas:Dock(FILL)

			ix.gui.menuInventoryContainer = canvas

			local panel = canvas:Add("ixInventory")
			panel:SetPos(0, 0)
			panel:SetDraggable(false)
			panel:SetSizable(false)
			panel:SetTitle(nil)
			panel.bNoBackgroundBlur = true
			panel.childPanels = {}
			
			panel.offsetX = 0
			panel.offsetY = 0

			local inventory = LocalPlayer():GetCharacter():GetInventory()

			if (inventory) then
				panel:SetInventory(inventory)
			end

			ix.gui.inv1 = panel

			if (ix.option.Get("openBags", true)) then
				for _, v in pairs(inventory:GetItems()) do
					if (!v.isBag) then
						continue
					end

					v.functions.View.OnClick(v)
				end
			end

			canvas.PerformLayout = canvasLayout
			canvas:Layout()
		end,
		
		OnSelected = function(info, container)
				local inventory = LocalPlayer():GetCharacter():GetInventory()

				if (inventory) then
					ix.gui.inv1:SetInventory(inventory)
				end
				
				-- ix.gui.inv1:RebuildItems()
			end,
		
		Sections = ix.config.Get("enableCrafting", false) and {
			crafting = {
				Create = function(info, container)
					if ix.config.Get("enableCrafting", false) then
						ix.gui["invCrafting"] = container:Add("ixCrafting")
						ix.gui["invCrafting"]:SetSize(ScrW() * 0.5, ScrH() * 0.7)
					end
				end,

				OnSelected = function(info, container)
					if ix.config.Get("enableCrafting", false) then ix.gui["invCrafting"]:RequestFocus() end
				end,
				
				PreOnDeselected = function(info, container)
					if ix.config.Get("enableCrafting", false) then ix.gui["invCrafting"]:DropItems() end
				end
			}
		} or nil
	}
end)

hook.Add("PostRenderVGUI", "ixInvHelper", function()
	local pnl = ix.gui.inv1

	hook.Run("PostDrawInventory", pnl)
end)
