ITEM.base = "base_consumable"

ITEM.name = "Drug Base"
ITEM.model = Model("models/willardnetworks/food/prop_bar_bottle_e.mdl")
ITEM.description = "A base for drug items."
ITEM.drink = "You apply the thing."
ITEM.category = "Drugs"
ITEM.width = 1
ITEM.height = 1
ITEM.uses = 1
ITEM.thirst = 1
ITEM.effects = {"drunk", 50}
ITEM.sounds = {"npc/barnacle/barnacle_gulp2.wav"}
-- ITEM.usesAlias = "Doses"
ITEM.useText = "Drink"
ITEM.useIcon = "icon16/drink.png"
ITEM.useAllIcon = "icon16/drink_empty.png"

function ITEM:GetNeeds()
	local needs = {}
	
	needs["hunger"] = self.hunger or nil
	needs["thirst"] = self.thirst or 1
	
	return needs
end

function ITEM:GetMessages()
	local messages = {}
	
	messages["Drink"] = self.drink
	messages["Drink All"] = self.drinkAll or self.drink
	messages.delay = self.messageDelay or 12
	
	return messages
end

function ITEM:GetSounds()
	return self.sounds
end

function ITEM:GetJunkItems()
	return self.junk
end

-- Called after the item is registered into the item tables.
ITEM:Hook("OnRegistered", "SetupDrugFunction", function(item, data)
	item.functions.Use.name = item.useText
	item.functions.Use.icon = "icon16/drink.png"

	item.functions.UseAll.name = item.useText .. " All"
	item.functions.UseAll.icon = "icon16/drink_empty.png"
end)

-- local OnBaseRegistered = ix.item.base[ITEM.base].OnRegistered
	
-- function ITEM:OnRegistered()
	-- if OnBaseRegistered then 
		-- OnBaseRegistered(self) 
	-- end
	
	-- self.needs = {["thirst"] = self.thirst or 1}
	-- self.messages = {delay = 12, ["Drink"] = self.Drink, ["Drink All"] = self.drinkAll or self.drink}
-- end