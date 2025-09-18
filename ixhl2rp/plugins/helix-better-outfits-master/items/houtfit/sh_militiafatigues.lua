
ITEM.name = "Vance Militia Fatigues"
ITEM.description = "A drab button-down and some cargo pants. It’s not glamorous at all, but there’s so many pockets!"
ITEM.category = "Clothing"
ITEM.model = "models/tnb/halflife2/world_torso_workshirt.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.outfitCategory = "torso"
ITEM.pacData = {}
ITEM.noResetBodyGroups = false

ITEM.replacements = {
	{"models/citizen/female_01.mdl", "models/militia/female_01.mdl"},
	{"models/citizen/female_02.mdl", "models/militia/female_02.mdl"},
	{"models/citizen/female_03.mdl", "models/militia/female_03.mdl"},
	{"models/citizen/female_04.mdl", "models/militia/female_04.mdl"},
	{"models/citizen/female_05.mdl", "models/militia/female_05.mdl"},
	{"models/citizen/female_06.mdl", "models/militia/female_06.mdl"},
	{"models/citizen/male_01.mdl", "models/militia/male_01.mdl"},
	{"models/citizen/male_02.mdl", "models/militia/male_02.mdl"},
	{"models/citizen/male_03.mdl", "models/militia/male_03.mdl"},
	{"models/citizen/male_04.mdl", "models/militia/male_04.mdl"},
	{"models/citizen/male_05.mdl", "models/militia/male_05.mdl"},
	{"models/citizen/male_06.mdl", "models/militia/male_06.mdl"},
	{"models/citizen/male_07.mdl", "models/militia/male_07.mdl"},
	{"models/citizen/male_08.mdl", "models/militia/male_08.mdl"},
	{"models/citizen/male_09.mdl", "models/militia/male_09.mdl"}
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

