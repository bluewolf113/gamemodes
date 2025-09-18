ITEM.base = "base_drink"

ITEM.name = "Refillable Base"
ITEM.model = Model("models/willardnetworks/food/prop_bar_bottle_e.mdl")
ITEM.description = "A base for items that can contain substances."
ITEM.category = "Miscellaneous"
ITEM.width = 1
ITEM.height = 1
ITEM.uses = 1
ITEM.sounds = {["Fill"] = "player/footsteps/slosh1.wav", ["Empty"] = "ambient/water/water_spray3.wav"}
ITEM.bDeleteOnConsumption = false

function ITEM:GetName()
	local ccID = self:GetContents()
	local ccTbl = ix.item.containerContents[self:GetContents()] or {}
	local sItemName = (self:GetData("uses", 0) > 0 and ccTbl.displayName) or "Empty"
	
	return self.name .. " (" .. sItemName .. ")"
end

function ITEM:GetStatusEffects()
	local statusEffects = {}
	
	local ccID = self:GetContents()
	local ccTbl = ix.item.containerContents[self:GetContents()] or {}
	
	statusEffects = ccTbl.GetStatusEffects and ccTbl:GetStatusEffects()
	
	return statusEffects
end

function ITEM:GetNeeds()
	local needs = {}
	
	local ccID = self:GetContents()
	local ccTbl = ix.item.containerContents[self:GetContents()] or {}
	
	needs["hunger"] = ccTbl.hunger or nil
	needs["thirst"] = ccTbl.thirst or 1
	
	return needs
end

function ITEM:GetMessages()
	local messages = {}
	
	local ccID = self:GetContents()
	local ccTbl = ix.item.containerContents[self:GetContents()] or {}
	
	messages["Drink"] = ccTbl.drink
	messages["Drink All"] = ccTbl.drinkAll or ccTbl.drink
	messages.delay = self.messageDelay or 12
	
	return messages
end

ITEM.functions.Fill = {
	name = "Fill",
	icon = "icon16/water.png",
	OnRun = function(item)
		local client = item.player
		local character = client:GetCharacter()
		
		local sound = item.sounds["Fill"]
		local newUses = (istable(item.uses) and item.uses["max"]) or item.uses
		
		local fluidSourceEnt = Schema:PlayerNearFluidSource(client)

		local cc = IsValid(fluidSourceEnt) and fluidSourceEnt:GetType() or "water_polluted"
		
		if fluidSourceEnt and not fluidSourceEnt:GetAmountMax() <= 0 then
			local amountLeft = fluidSourceEnt:GetAmountLeft()		
			local newAmount = math.Clamp(amountLeft - newUses, 0, fluidSourceEnt:GetAmountMax())
			
			fluidSourceEnt:SetAmountLeft(newAmount)
		end

		item:SetContents(cc)		
		item:SetData("uses", newUses)
		-- item:SetUses("uses", item.uses)
		
		client:EmitSound(sound, 75, 150, 0.5)

		return false
	end,
	OnCanRun = function(item)
		local client = item.player
		local currUses = item:GetData("uses")
		local maxUses = (istable(item.uses) and item.uses["max"]) or item.uses
		local fluidSourceEnt = Schema:PlayerNearFluidSource(client)
		return currUses < maxUses and ((IsValid(fluidSourceEnt) and (fluidSourceEnt:GetAmountMax() <= 0 or fluidSourceEnt:GetAmountLeft() > 0)) or client:WaterLevel() > 0)
	end
}

ITEM.functions.Empty = {
	name = "Empty",
	icon = "icon16/water.png",
	OnRun = function(item)
		local client = item.player
		local character = client:GetCharacter()
		local sound = item.sounds["Empty"]

		item:SetContents("empty")		
		item:SetData("uses", 0)
		-- item:SetUses("uses", item.uses)
		
		client:EmitSound(sound, 75, 150, 0.5)

		return false
	end,
	OnCanRun = function(item)
		local currUses = item:GetData("uses")
		return currUses and currUses > 0
	end
}

function ITEM:GetContentsTable()
		local uniqueID = self:GetContents()	
		local ccTbl = ix.item.containerContents[uniqueID]
		
		return ccTbl
end
	
function ITEM:GetContents()
	local ccData = self:GetData("containerContents", nil)	
	return ccData or "empty"
end

function ITEM:SetContents(uniqueID)
	local ccTbl = ix.item.containerContents[uniqueID]
	if ccTbl then
		self:SetData("containerContents", uniqueID)
	else
		self:SetData("containerContents", "empty")
	end
end