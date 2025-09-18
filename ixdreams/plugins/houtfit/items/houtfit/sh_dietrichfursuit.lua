ITEM.name = "Hans Dietrich Mascot Suit"
ITEM.description = "An incredibly lifelike synthetic mascot-suit recreation of Hans Dietrich. It smells faintly of Lavender."
ITEM.model = "models/hls/alyxports/wood_crate004.mdl"
ITEM.skin = 0
ITEM.noResetBodyGroups = false
ITEM.noResetSkin = false
ITEM.height = 2
ITEM.width = 2
ITEM.category = "Clothing"
ITEM.outfitCategory = "Outfit"
ITEM.replacements = {
    {"models/willardnetworks/citizens/male01.mdl", "models/players/mj_vp_jonathan_npc.mdl", 0, "00g00000"},
    {"models/willardnetworks/citizens/male02.mdl", "models/players/mj_vp_jonathan_npc.mdl", 0, "00g00000"},
    {"models/willardnetworks/citizens/male03.mdl", "models/players/mj_vp_jonathan_npc.mdl", 0, "00g00000"},
    {"models/willardnetworks/citizens/male04.mdl", "models/players/mj_vp_jonathan_npc.mdl", 0, "00g00000"},
    {"models/willardnetworks/citizens/male05.mdl", "models/players/mj_vp_jonathan_npc.mdl", 0, "00g00000"},
    {"models/willardnetworks/citizens/male06.mdl", "models/players/mj_vp_jonathan_npc.mdl", 0, "00g00000"},
    {"models/willardnetworks/citizens/male07.mdl", "models/players/mj_vp_jonathan_npc.mdl", 0, "00g00000"},
    {"models/willardnetworks/citizens/male08.mdl", "models/players/mj_vp_jonathan_npc.mdl", 0, "00g00000"},
    {"models/willardnetworks/citizens/male09.mdl", "models/players/mj_vp_jonathan_npc.mdl", 0, "00g00000"},
    {"models/willardnetworks/citizens/male10.mdl", "models/players/mj_vp_jonathan_npc.mdl", 0, "00g00000"},
    {"models/willardnetworks/citizens/female_01.mdl", "models/players/mj_vp_jonathan_npc.mdl", 0, "00g00000"},
    {"models/willardnetworks/citizens/female_02.mdl", "models/players/mj_vp_jonathan_npc.mdl", 0, "00g00000"},
    {"models/willardnetworks/citizens/female_03.mdl", "models/players/mj_vp_jonathan_npc.mdl", 0, "00g00000"},
    {"models/willardnetworks/citizens/female_04.mdl", "models/players/mj_vp_jonathan_npc.mdl", 0, "00g00000"},
    {"models/willardnetworks/citizens/female_06.mdl", "models/players/mj_vp_jonathan_npc.mdl", 0, "00g00000"},
    {"models/willardnetworks/citizens/female_07.mdl", "models/players/mj_vp_jonathan_npc.mdl", 0, "00g00000"},
	{"models/conceptbine_policeforce/conceptpolice_nemez.mdl", "models/players/mj_vp_jonathan_npc.mdl", 0, "00g00000"},
	{"models/conceptbine_policeforce/conceptpolice_nemez_pm1.mdl", "models/players/mj_vp_jonathan_npc.mdl", 0, "00g00000"},
	{"models/conceptbine_policeforce/conceptpolice_nemez_pm2.mdl", "models/players/mj_vp_jonathan_npc.mdl", 0, "00g00000"},
	{"models/conceptbine_policeforce/conceptpolice_nemez_pose.mdl", "models/players/mj_vp_jonathan_npc.mdl", 0, "00g00000"},
	{"models/conceptbine_policeforce/conceptpolice_wst.mdl", "models/players/mj_vp_jonathan_npc.mdl", 0, "00g00000"},
	{"models/conceptbine_policeforce/conceptpolice_wst_pose.mdl", "models/players/mj_vp_jonathan_npc.mdl", 0, "00g00000"}

   
}

local defaultArmor = 100

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