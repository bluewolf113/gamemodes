ITEM.base = "base_food"

ITEM.name = "Calorie Paste"
ITEM.model = Model("models/willardnetworks/food/ration_box.mdl")
ITEM.width = 2
ITEM.height = 1
ITEM.description = "Gelatinated calorie paste produced for rationing. Clamp brandings."
ITEM.eat = "Lifeless plastic sludge characteristic of the old ways."
ITEM.category = "Food"
ITEM.hunger = 4
ITEM.uses = 2
ITEM.usesAlias = {"Serving", "Servings"}
ITEM.junk = {["emptybox5"] =  1}

if CLIENT then
    function ITEM:PopulateTooltip(tooltip)
        local panel = tooltip:AddRowAfter("name", "uses")
        panel:SetBackgroundColor(derma.GetColor("Warning", tooltip))

        local currUses = self:GetData("uses", nil)
        local usesAlias = self.usesAlias or {"Use", "Uses"} -- Default singular/plural alias

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