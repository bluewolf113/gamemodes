ITEM.name = "Combine Engineering Core Senior Hazard Suit MK1"
ITEM.description = "A hazmat suit worn by the Senior Engineers of the Combine Engineering Core, offering protection against hazardous environment. It features a working AXON 3 bodycam, a safety harness, holsters, and a built in filtration system. The suit also has a slightly functioning biosignal that can only be read by Chief Engineers."
ITEM.model = "models/models/illusion/eftcontainers/weaponcase.mdl"
ITEM.skin = 0
ITEM.newSkin = 6
ITEM.noResetBodyGroups = true
ITEM.height = 1
ITEM.width = 1
ITEM.category = "Clothing"
ITEM.outfitCategory = "Top"
ITEM.replacements = {
    {"models/willardnetworks/citizens/male01.mdl", "models/npc/engineer_male.mdl", 6, "00g00000"},
    {"models/willardnetworks/citizens/male02.mdl", "models/npc/engineer_male.mdl", 6, "00g00000"},
    {"models/willardnetworks/citizens/male03.mdl", "models/npc/engineer_male.mdl", 6, "00g00000"},
    {"models/willardnetworks/citizens/male04.mdl", "models/npc/engineer_male.mdl", 6, "00g00000"},
    {"models/willardnetworks/citizens/male05.mdl", "models/npc/engineer_male.mdl", 6, "00g00000"},
    {"models/willardnetworks/citizens/male06.mdl", "models/npc/engineer_male.mdl", 6, "00g00000"},
    {"models/willardnetworks/citizens/male07.mdl", "models/npc/engineer_male.mdl", 6, "00g00000"},
    {"models/willardnetworks/citizens/male08.mdl", "models/npc/engineer_male.mdl", 6, "00g00000"},
    {"models/willardnetworks/citizens/male09.mdl", "models/npc/engineer_male.mdl", 6, "00g00000"},
    {"models/willardnetworks/citizens/male10.mdl", "models/npc/engineer_male.mdl", 6, "00g00000"},
    {"models/willardnetworks/citizens/female_01.mdl", "models/npc/engineer_female.mdl", 6, "00g00000"},
    {"models/willardnetworks/citizens/female_02.mdl", "models/npc/engineer_female.mdl", 6, "00g00000"},
    {"models/willardnetworks/citizens/female_03.mdl", "models/npc/engineer_female.mdl", 6, "00g00000"},
    {"models/willardnetworks/citizens/female_04.mdl", "models/npc/engineer_female.mdl", 6, "00g00000"},
    {"models/willardnetworks/citizens/female_06.mdl", "models/npc/engineer_female.mdl", 6, "00g00000"},
    {"models/willardnetworks/citizens/female_07.mdl", "models/npc/engineer_female.mdl", 6, "00g00000"}

   
}

local defaultArmor = 80

ITEM:PostHook("Equip", function(item)
    local armor = item:GetData("armor")
    if not armor then
        item.player:SetArmor(defaultArmor)
        item:SetData("armor", defaultArmor)
    else
        item.player:SetArmor(math.min(armor, defaultArmor))
    end
end)

ITEM:PostHook("EquipUn", function(item)
    item:SetData(item.player:Armor())
    item.player:SetArmor(0)
end)

ITEM:PostHook("drop", function(item)
    item:SetData(item.player:Armor())
    item.player:SetArmor(0)
end)

function ITEM:OnEquipped()
    self.player:EmitSound( "stalkersound/inv_disassemble_cloth_fast_2.ogg", 100, 50, 0.30)
end