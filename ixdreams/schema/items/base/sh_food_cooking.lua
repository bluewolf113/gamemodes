ITEM.base = "base_food"

ITEM.name = "Cooking Base"
ITEM.model = Model("models/willardnetworks/food/prop_bar_bottle_e.mdl")
ITEM.description = "A base for food items."
ITEM.eat = "This thing is uncooked."
ITEM.eatCooked = "This thing is cooked."
ITEM.category = "Food"
ITEM.width = 1
ITEM.height = 1
ITEM.uses = 1
ITEM.hunger = 1
ITEM.hungerCooked = 10
ITEM.materialRaw = ""
ITEM.materialCooked = ""

function ITEM:GetNeeds()
	local needs = {}
	
	needs["hunger"] = (self:GetCookedState() > 0 and self.hungerCooked) or self.hunger or 1
	needs["thirst"] = (self:GetCookedState() > 0 and self.thirstCooked) or self.thirst or nil
	
	return needs
end

function ITEM:GetMessages()
	local messages = {}
	
	messages["Eat"] = (self:GetCookedState() > 0 and self.eatCooked) or self.eat
	messages["Eat All"] = (self:GetCookedState() > 0 and self.eatAllCooked) or self.eatAll or messages["Eat"]
	messages.delay = self.messageDelay or 12
	
	return messages
end

function ITEM:GetMaterial()
	local itemCookedValue = self:GetCookedState()
	return (itemCookedValue < 10 and self.materialRaw) or (itemCookedValue == 10 and self.materialCooked) or nil
end

function ITEM:GetName()
	local sStateDisplayName = self:GetCookedState(true)
	
	return self.name .. " (" .. sStateDisplayName .. ")"
end

function ITEM:GetCookedState(bReturnString)
	local itemCookedValue = self:GetData("cooked", 0)
	local sStateDisplayName = self:GetData("cookedDisplayNameOverride", nil) or (itemCookedValue == 0 and "Raw") or (itemCookedValue < 10 and "Partly cooked") or (itemCookedValue == 10 and "Cooked")
	
	return (bReturnString and sStateDisplayName) or itemCookedValue
end

ITEM.functions.Cook = {
	name = "Cook",
	icon = "icon16/fire.png",
	OnRun = function(item)
		local client = item.player
		local character = client:GetCharacter()
		local target = client:GetEyeTrace().Entity
		local sound = "ambient/levels/canals/toxic_slime_sizzle4.wav"
		local cookTime = item.cookTime or 5

		client:SetAction("Cooking...", cookTime)

		client:DoStaredAction(target, function()
			item:SetData("cooked", 10)
			client:EmitSound(sound, 75, 100, 0.5)
		end, cookTime, function()
			item:SetData("cooked", 5)
			client:EmitSound(sound, 75, 140, 0.2)
			client:SetAction()
		end)
		
		client:EmitSound(sound, 75, 100, 0.5)

		return false
	end,
	OnCanRun = function(item)
		local client = item.player
		local currUses = item:GetData("uses", 0)
		local itemCookedValue = item:GetData("cooked", 0)
		local target = client:GetEyeTrace().Entity

		return target:GetClass() == "ix_cookingsource" and target:GetPos():DistToSqr(client:GetPos()) < 3000^2 and currUses > 0 and itemCookedValue < 10
	end
}

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