ITEM.name = "Civil Protection Force Uniform"
ITEM.description = "An average, standard-issue uniform given to all Civil Protection Force enlistees. Equipped with a standard issue faceplate, CIMS internal regulation suit, a stab-proof protective uniform, a stun-baton clip, and a sidearm holster."
ITEM.model = "models/tnb/items/shirt_metrocop.mdl"
ITEM.skin = 0
ITEM.newSkin = 0
ITEM.noResetBodyGroups = true
ITEM.noResetSkins = false
ITEM.height = 1
ITEM.width = 1
ITEM.category = "Clothing"
ITEM.outfitCategory = "Top"
ITEM.replacements = {
    {"models/willardnetworks/citizens/male01.mdl", "models/conceptbine_policeforce/conceptpolice_nemez.mdl", 0, "00g00000"},
    {"models/willardnetworks/citizens/male02.mdl", "models/conceptbine_policeforce/conceptpolice_nemez.mdl", 0, "00g00000"},
    {"models/willardnetworks/citizens/male03.mdl", "models/conceptbine_policeforce/conceptpolice_nemez.mdl", 0, "00g00000"},
    {"models/willardnetworks/citizens/male04.mdl", "models/conceptbine_policeforce/conceptpolice_nemez.mdl", 0, "00g00000"},
    {"models/willardnetworks/citizens/male05.mdl", "models/conceptbine_policeforce/conceptpolice_nemez.mdl", 0, "00g00000"},
    {"models/willardnetworks/citizens/male06.mdl", "models/conceptbine_policeforce/conceptpolice_nemez.mdl", 0, "00g00000"},
    {"models/willardnetworks/citizens/male07.mdl", "models/conceptbine_policeforce/conceptpolice_nemez.mdl", 0, "00g00000"},
    {"models/willardnetworks/citizens/male08.mdl", "models/conceptbine_policeforce/conceptpolice_nemez.mdl", 0, "00g00000"},
    {"models/willardnetworks/citizens/male09.mdl", "models/conceptbine_policeforce/conceptpolice_nemez.mdl", 0, "00g00000"},
    {"models/willardnetworks/citizens/male10.mdl", "models/conceptbine_policeforce/conceptpolice_nemez.mdl", 0, "00g00000"},
    {"models/willardnetworks/citizens/female_01.mdl", "models/conceptbine_policeforce/conceptpolice_nemez.mdl", 0, "00g00000"},
    {"models/willardnetworks/citizens/female_02.mdl", "models/conceptbine_policeforce/conceptpolice_nemez.mdl", 0, "00g00000"},
    {"models/willardnetworks/citizens/female_03.mdl", "models/conceptbine_policeforce/conceptpolice_nemez.mdl", 0, "00g00000"},
    {"models/willardnetworks/citizens/female_04.mdl", "models/conceptbine_policeforce/conceptpolice_nemez.mdl", 0, "00g00000"},
    {"models/willardnetworks/citizens/female_06.mdl", "models/conceptbine_policeforce/conceptpolice_nemez.mdl", 0, "00g00000"},
    {"models/willardnetworks/citizens/female_07.mdl", "models/conceptbine_policeforce/conceptpolice_nemez.mdl", 0, "00g00000"}

   
}

local defaultArmor = 25

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