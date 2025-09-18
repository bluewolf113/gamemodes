ITEM.name = "PCV Uniform"
ITEM.description = "A durable, high-performance vest designed for heavy combat, used by HECU soldiers. It offers robust protection against ballistic and energy weapons, particularly pulse-based attacks, and can withstand a few direct shots. Covering vital areas such as the neck, shoulders, and groin, the PCV ensures full-body defense in combat. It passively recharges over time, making it a reliable choice for prolonged engagements and an essential endgame suit of armor."
ITEM.category = "Clothing"
ITEM.model = "models/willardnetworks/update_items/armor03_item.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.iconCam = {
    pos = Vector(-39.23, -7.19, 195.95),
    ang = Angle(76.94, 10.12, 0),
    fov = 4.05
}

local Green = Color(0, 255, 0)

function ITEM:PopulateTooltip(tooltip)
    local data = tooltip:AddRow("data")
    data:SetBackgroundColor(Green, tooltip)
    data:SetText("Green Contraband")
    data:SetFont("BudgetLabel")
    data:SetExpensiveShadow(0.5)
    data:SizeToContents()
end

local defaultArmor = 200

ITEM:PostHook("Equip", function(item)
    local armor = item:GetData("armor")
    if not armor then
        item.player:SetArmor(defaultArmor)
        item:SetData("armor", defaultArmor)
    else
        item.player:SetArmor(math.min(armor, defaultArmor))
    end
end)

ITEM.outfitCategory = "Torso"

ITEM.bodyGroups = {
    ["torso"] = 39
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
}