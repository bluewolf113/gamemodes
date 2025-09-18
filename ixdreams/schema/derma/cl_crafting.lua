PANEL = {}
DEFINE_BASECLASS("DPanel")

local Schema = Schema

-- local function DoCraftingAttempt()
	-- local inventory = LocalPlayer():GetCharacter():GetInventory()
	-- if inventory then
		-- local bHasItems = false
		-- for uniqueID, itemIDs in pairs(self.availableRecipes or {}) do
			-- print("availableRecipes != {}")
			-- local recipeTable = ix.crafting.GetRecipeTable(uniqueID)
			-- local inputItems = recipeTable.inputs
			
			-- local inputInvX = self.inPanel:GetOffsetX()
			-- local inputInvY = self.inPanel:GetOffsetY()
			-- local inputW, inputH = self.inPanel:GetGridSize()
			-- local outputW, outputH = self.outPanel:GetGridSize()
			
			-- bHasItems = ix.crafting.GetInputItemIDs(inventory:GetID(), inputItems, inputInvX, inputInvY, inputW, inputH)
			-- print("bHasItems = " .. tostring(bHasItems))
			-- if bHasItems then 
				-- print("starting net message")
				-- net.Start("ixDoCraftingAttempt")
					-- net.WriteString(uniqueID)
					-- net.WriteString(self.workstation or "none")
					-- net.WriteInt(inputInvX)
					-- net.WriteInt(inputInvY)
					-- net.WriteInt(inputInvW)
					-- net.WriteInt(inputInvH)
					-- net.WriteInt(outputInvX)
					-- net.WriteInt(outputInvY)
					-- net.WriteInt(outputW)
					-- net.WriteInt(outputH)
				-- net.Broadcast()
				-- break 
			-- end
		-- end
	-- end
-- end

function PANEL:Init()

	local character = LocalPlayer():GetCharacter()
	local inventory = character:GetInventory()

	self.invPanel = self:Add("ixInventory")
	self.invPanel:SetPos(0, 0)
	self.invPanel:SetDraggable(false)
	self.invPanel:SetSizable(false)
	self.invPanel:SetTitle(nil)
	self.invPanel.bNoBackgroundBlur = true
	self.invPanel.childPanels = {}
	
	if (inventory) then
		self.invPanel:SetInventory(inventory)
	end
	
	local invW, invH = self.invPanel:GetGridSize()
	
	offsetX = invW
	offsetY = invH
	
	self.inPanel = self:Add("ixInventory")
	self.inPanel:SetPos(0, 360)
	self.inPanel:SetDraggable(false)
	self.inPanel:SetSizable(false)
	self.inPanel:SetTitle(nil)
	self.inPanel.bNoBackgroundBlur = true
	self.inPanel.childPanels = {}
	self.inPanel.bDumpItems = true
	self.inPanel:SetOffsets(offsetX, offsetY)
	
	self.inPanel:SetGridSize(3, 3, true)
	
	if (inventory) then
		self.inPanel:SetInventory(inventory)
	end
	
	local inInvW, inInvH = self.inPanel:GetGridSize()
	
	self.outPanel = self:Add("ixInventory")
	self.outPanel:SetPos(360, 360)
	self.outPanel:SetDraggable(false)
	self.outPanel:SetSizable(false)
	self.outPanel:SetTitle(nil)
	self.outPanel.bNoBackgroundBlur = true
	self.outPanel.childPanels = {}
	self.outPanel.bDumpItems = true
	self.outPanel:SetOffsets(offsetX + inInvW, offsetY + inInvH)
	
	self.outPanel:SetGridSize(3, 3, true)
	
	if (inventory) then
		self.outPanel:SetInventory(inventory)
	end
	
	self.outPanel:SetNoDrop(true)
	
	self:LoadAvailableRecipes()

	self.craftButton = self:Add("DButton")
	self.craftButton:SetPos(600, 600)
	self.craftButton:SetImage("ixgui/crafting.png")
	self.craftButton:SetSize(30, 30)
	self.craftButton.DoClick = function()
		self:DoCraftingAttempt()
	end
end

function PANEL:DoCraftingAttempt()
	local inputInvX = self.inPanel:GetOffsetX() + 1
	local inputInvY = self.inPanel:GetOffsetY() + 1
	local outputInvX = self.outPanel:GetOffsetX() + 1
	local outputInvY = self.outPanel:GetOffsetY() + 1
	local inputW, inputH = self.inPanel:GetGridSize()
	local outputW, outputH = self.outPanel:GetGridSize()
	
	ix.crafting.DoCraftingAttempt(LocalPlayer():GetCharacter():GetInventory(), "none", inputInvX, inputInvY, outputInvX, outputInvY, inputW, inputH, outputW, outputH)
end

function PANEL:SetWorkstation(workstation)
	self.workstation = workstation
end

function PANEL:LoadAvailableRecipes()
	local inventory = LocalPlayer():GetCharacter():GetInventory()
	self.availableRecipes = ix.crafting.GetAvailableRecipes(inventory, self.workstation or "none")
end

function PANEL:RefreshIcons()
	self.invPanel:RefreshIcons()
	self.inPanel:RefreshIcons()
	self.outPanel:RefreshIcons()
end

function PANEL:DropItems()
	self.invPanel:DropExtraItems()
end

function PANEL:GetOutputPanel()
	return self.outPanel
end

function PANEL:GetInvPanels()
	return {invPanel = self.invPanel, inPanel = self.inPanel, outPanel = self.outPanel}
end

function PANEL:GetActiveGrid(x, y)
	local invW, invH = self.invPanel:GetGridSize()
	local inW, inH = self.inPanel:GetGridSize()
	local outW, outH = self.outPanel:GetGridSize()
	
	if x > 0 and y > 0 and x <= invW and y <= invH then
		return self.invPanel
	elseif x > invW and y > invH and x <= inW and y <= inH then
		return self.inPanel
	elseif x > inW and y > inH and x <= outW and y <= outH then
		return self.outPanel
	end
end

vgui.Register("ixCrafting", PANEL, "DPanel")