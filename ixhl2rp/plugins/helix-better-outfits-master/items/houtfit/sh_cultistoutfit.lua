
ITEM.name = "Cultist Outfit"
ITEM.description = "A plain, heavy robe worn by Benefactor cultists."
ITEM.category = "Clothing"
ITEM.model = "models/tnb/halflife2/world_torso_jacket_black.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.outfitCategory = "model"
ITEM.pacData = {}
ITEM.noResetBodyGroups = false

ITEM.replacements = {
	{"models/citizen/female_01.mdl", "models/female_killer.mdl"},
	{"models/citizen/female_02.mdl", "models/female_killer.mdl"},
	{"models/citizen/female_03.mdl", "models/female_killer.mdl"},
	{"models/citizen/female_04.mdl", "models/female_killer.mdl"},
	{"models/citizen/female_05.mdl", "models/female_killer.mdl"},
	{"models/citizen/female_06.mdl", "models/female_killer.mdl"},
	{"models/citizen/male_01.mdl", "models/male_killer.mdl"},
	{"models/citizen/male_02.mdl", "models/male_killer.mdl"},
	{"models/citizen/male_03.mdl", "models/male_killer.mdl"},
	{"models/citizen/male_04.mdl", "models/male_killer.mdl"},
	{"models/citizen/male_05.mdl", "models/male_killer.mdl"},
	{"models/citizen/male_06.mdl", "models/male_killer.mdl"},
	{"models/citizen/male_07.mdl", "models/male_killer.mdl"},
	{"models/citizen/male_08.mdl", "models/male_killer.mdl"},
	{"models/citizen/male_09.mdl", "models/male_killer.mdl"}
}

--[[
-- This will change a player's skin after changing the model. Keep in mind it starts at 0.
ITEM.newSkin = 1
-- This will change a certain part of the model.
ITEM.replacements = {"group01", "group02"}
-- This will change the player's model completely.
ITEM.replacements = "models/manhack.mdl"
-- This will have multiple replacements.
ITEM.replacements = {
	{"male", "female"},
	{"group01", "group02"}
}
-- This will apply body groups.
ITEM.bodyGroups = {
	["blade"] = 1,
	["bladeblur"] = 1
}
]]--

