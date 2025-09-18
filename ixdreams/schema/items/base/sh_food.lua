ITEM.base = "base_consumable"

ITEM.name = "Food Base"
ITEM.model = Model("models/willardnetworks/food/prop_bar_bottle_e.mdl")
ITEM.description = "A base for food items."
ITEM.category = "Food"
ITEM.width = 1
ITEM.height = 1
ITEM.uses = 1
ITEM.hunger = 1
ITEM.sounds = {"player/footsteps/sand1.wav"}
-- ITEM.usesAlias = "Bites"
ITEM.useText = "Eat"
ITEM.useIcon = "icon16/heart.png" 
ITEM.useAllIcon = "icon16/heart_add.png"

function ITEM:GetNeeds()
	local needs = {}
	
	needs["hunger"] = self.hunger or 1
	needs["thirst"] = self.thirst or nil
	needs["nutrition"] = self.nutrition or nil
	
	return needs
end

function ITEM:GetMessages()
	local messages = {}
	
	messages["Eat"] = self.eat
	messages["Eat All"] = self.eatAll or self.eat
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
ITEM:Hook("OnRegistered", "SetupFoodFunction", function(item, data)
	item.messages = {delay = 12, ["Eat"] = item.eat, ["Eat All"] = item.eatAll or item.eat}

	item.functions.Use.name = item.useText
	item.functions.Use.icon = "icon16/heart.png"

	item.functions.UseAll.name = item.useText .. " All"
	item.functions.UseAll.icon = "icon16/heart_add.png"
end)

if CLIENT then
    function ITEM:PopulateTooltip(tooltip)
        local panel = tooltip:AddRowAfter("name", "uses")
        panel:SetBackgroundColor(derma.GetColor("Warning", tooltip))

        local currUses = self:GetData("uses", nil)
        local usesAlias = self.usesAlias or {"Serving", "Servings"} -- Default singular/plural alias

        if currUses then
            local alias = (currUses == 1) and usesAlias[1] or usesAlias[2]
            panel:SetText(tostring(currUses) .. " " .. alias .. " left")
            panel:SizeToContents()
        end

        -- Calories per serving display
        local hungerValue = self.hunger or 0 -- Ensure default value if undefined
        local calories = hungerValue * 20
        local caloriePanel = tooltip:AddRowAfter("uses", "calories")
        caloriePanel:SetBackgroundColor(derma.GetColor("Warning", tooltip))
        caloriePanel:SetText(tostring(calories) .. " calories per serving")
        caloriePanel:SizeToContents()
    end
end

-- local OnBaseRegistered = ix.item.base[ITEM.base].OnRegistered
	
-- function ITEM:OnRegistered()
	-- if OnBaseRegistered then 
		-- OnBaseRegistered(self) 
	-- end
	
	-- self.needs = {["hunger"] = self.hunger or 1}
	-- self.messages = {delay = 12, ["Eat"] = self.eat, ["Eat All"] = self.eatAll or self.eat}
-- end