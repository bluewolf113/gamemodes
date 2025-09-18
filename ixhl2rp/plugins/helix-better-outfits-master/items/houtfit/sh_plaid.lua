
ITEM.name = "Plaid Coat"
ITEM.description = "Stylish and warm. Well, I dunno about stylish, but it’s not so bad in the dead of winter."
ITEM.category = "Clothing"
ITEM.model = "models/props_c17/BriefCase001a.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.outfitCategory = "torso"
ITEM.pacData = {}
ITEM.noResetBodyGroups = true
ITEM.replacements = "models/humans/group02/female_02.mdl"
ITEM.allowedModels = {
	"models/humans/group01/female_01.mdl",
	"models/citizen/female_02.mdl",
	"models/citizen/female_03.mdl",
	"models/citizen/female_04.mdl",
	"models/citizen/female_05.mdl",
	"models/citizen/female_06.mdl",
	"models/citizen/male_01.mdl",
	"models/citizen/male_02.mdl",
	"models/citizen/male_03.mdl",
	"models/citizen/male_04.mdl",
	"models/citizen/male_06.mdl",
	"models/citizen/male_07.mdl",
	"models/citizen/male_08.mdl",
	"models/citizen/male_09.mdl"
}

ITEM.functions.Wash = {
    name = "Wash Outfit",
    tip = "Clean your outfit if you're near a washing machine.",
    icon = "icon16/wrench.png",
    OnRun = function(item)
        local client = item.player
        local nearbyMachine = false
        local washingSound = "ambient/machines/combine_terminal_idle1.wav" -- Change this to a valid washing sound file!

        -- Scan for washing machines within 140 units
        for _, ent in ipairs(ents.FindByClass("ix_washingmachine")) do
            if IsValid(ent) and client:GetPos():Distance(ent:GetPos()) <= 50 then
                nearbyMachine = ent
                break
            end
        end

        if not nearbyMachine then
            client:Notify("You're not near a washing machine!")
            return false
        end

        item:SetData("cleanliness", 0)
        client:Notify("Your outfit has been washed and is now clean!")

        -- Play sound from the washing machine entity
        nearbyMachine:EmitSound(washingSound, 75, 120) -- Volume: 75, Pitch: 100 (adjustable)

        return false
    end,

    OnCanRun = function(item)
        -- Wash option is **only available if the outfit is unequipped**
        return item:GetData("cleanliness", 0) > 0 and not item:GetData("equip")
    end
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

