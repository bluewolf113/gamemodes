ITEM.name = "GP-6 Soviet Gasmask"
ITEM.description = "Provides adequate protection against harmful fumes, gases, and some foul odours."
ITEM.category = "Clothing"
ITEM.model = "models/willardnetworks/clothingitems/head_gasmask.mdl"
ITEM.width = 2
ITEM.height = 2
ITEM.iconCam = {
    pos = Vector(-117.67, -98.6, 71.58),
    ang = Angle(25, 400, 0),
    fov = 4.96
}

local Green = Color(0, 255, 0)

function ITEM:PopulateTooltip(tooltip)
    local data = tooltip:AddRow("data")
    data:SetBackgroundColor(Green, tooltip)
    data:SetText("Green Contraband")
    data:SetFont("BudgetLabel")
    data:SetExpensiveShadow(0.5)
    data:SizeToContents()

    local durability = self:GetData("gasmaskdurability", 0)
	local max = self.gasmaskDurabilityMax or 250

	local row = tooltip:AddRow("filterStatus")

	if durability > 0 then
		local percent = math.ceil((durability / max) * 100)
		local status

		if percent >= 90 then
			status = "Pristine"
		elseif percent >= 60 then
			status = "Worn"
		elseif percent >= 30 then
			status = "Damaged"
		else
			status = "Critical"
		end

		row:SetText("Filter Status: " .. status)
		row:SetBackgroundColor(Color(100, 200, 255)) -- light blue
	else
		row:SetText("No filter installed.")
		row:SetBackgroundColor(Color(255, 100, 100)) -- light red
	end

	row:SizeToContents()
end

ITEM.outfitCategory = "Face"
ITEM.bodyGroups = {
    ["headstrap"] = 3
}

ITEM.allowedModels = {
    "models/willardnetworks/citizens/female_01.mdl",
    "models/willardnetworks/citizens/female_02.mdl",
    "models/willardnetworks/citizens/female_03.mdl",
    "models/willardnetworks/citizens/female_04.mdl",
    "models/willardnetworks/citizens/female_06.mdl",
    "models/willardnetworks/citizens/female_07.mdl",
    
    "models/willardnetworks/citizens/male01.mdl",
    "models/willardnetworks/citizens/male02.mdl",
    "models/willardnetworks/citizens/male03.mdl",
    "models/willardnetworks/citizens/male04.mdl",
    "models/willardnetworks/citizens/male05.mdl",
    "models/willardnetworks/citizens/male06.mdl",
    "models/willardnetworks/citizens/male07.mdl",
    "models/willardnetworks/citizens/male08.mdl",
    "models/willardnetworks/citizens/male09.mdl",
    "models/willardnetworks/citizens/male10.mdl",

    "models/humans/pandafishizens/male_07.mdl"
}
