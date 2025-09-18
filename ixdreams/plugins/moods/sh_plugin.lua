local PLUGIN = PLUGIN

PLUGIN.name = "Moods"
PLUGIN.description = "Allows you to set different animation moods for standing, walking, and running."
PLUGIN.author = "Riggs, updated by Copilot"
PLUGIN.schema = "Any"

PLUGIN.moodAffectedWeapons = {
    ["ix_hands"] = true,
    ["ix_keys"] = true,
    ["weapon_hl2_suitcase"] = true,
}

PLUGIN.moods = {}

PLUGIN.moods["citizen_male"] = {
    stand = {
        {sequence = "lineidle03"},
        {sequence = "lineidle02"},
        {sequence = "lineidle01"},
        {sequence = "scaredidle"},
        {sequence = "d1_t01_luggage_idle"}
    },
    walk = {
        {sequence = "plaza_walk_all"},
        {sequence = "pace_all"},
        {sequence = "walk_all_moderate"},
        {sequence = "walk_panicked_all"},
        {sequence = "luggage_walk_all"}
    },
    run = {
        {sequence = "run_all_panicked"},
        {sequence = "sprint_all"},
        {sequence = "crouchrunall1"},
        {sequence = "run_protected_all"}
    }
}

PLUGIN.moods["citizen_female"] = {
    stand = {
        {sequence = "lineidle01"},
        {sequence = "holdhandslooparms", isGesture = true}, -- gesture-style mood
        {sequence = "g_arlene_postidle_headuplooparms", isGesture = true},
        {sequence = "urgenthandsweepcrouchlooparms", isGesture = true} -- gesture-style mood
    },
    walk = {
        {sequence = "walk_all_moderate"},
        {sequence = "walk_panicked_all"},
        {sequence = "holdhandslooparms", isGesture = true}, -- gesture-style mood
        {sequence = "urgenthandsweepcrouchlooparms", isGesture = true}
    },
    run = {
        {sequence = "crouchrunall1"},
        {sequence = "run_panicked__all"},
        {sequence = "run_panicked_2_all"},
        {sequence = "run_panicked3__all"},
        {sequence = "run_protected_all"},
    }
}

ix.char.RegisterVar("moodStand", {
    field = "moodStand",
    fieldType = ix.type.number,
    default = 0,
})

ix.char.RegisterVar("moodWalk", {
    field = "moodWalk",
    fieldType = ix.type.number,
    default = 0,
})

ix.char.RegisterVar("moodRun", {
    field = "moodRun",
    fieldType = ix.type.number,
    default = 0,
})

local function getMoodList(ply, type)
    local modelClass = ix.anim.GetModelClass(ply:GetModel())
    local moodSet = PLUGIN.moods[modelClass]
    return moodSet and moodSet[type]
end

ix.command.Add("MoodStand", {
    description = "Set your standing animation mood.",
    arguments = {ix.type.number},
    OnCanRun = function(self, ply, index)
        local list = getMoodList(ply, "stand")
        return list and index >= 1 and index <= #list
    end,
    OnRun = function(self, ply, index)
        ply:GetCharacter():SetMoodStand(index)
    end
})

ix.command.Add("MoodWalk", {
    description = "Set your walking animation mood.",
    arguments = {ix.type.number},
    OnCanRun = function(self, ply, index)
        local list = getMoodList(ply, "walk")
        return list and index >= 1 and index <= #list
    end,
    OnRun = function(self, ply, index)
        ply:GetCharacter():SetMoodWalk(index)
    end
})

ix.command.Add("MoodRun", {
    description = "Set your running animation mood.",
    arguments = {ix.type.number},
    OnCanRun = function(self, ply, index)
        local list = getMoodList(ply, "run")
        return list and index >= 1 and index <= #list
    end,
    OnRun = function(self, ply, index)
        ply:GetCharacter():SetMoodRun(index)
    end
})

ix.command.Add("MoodReset", {
    description = "Reset your standing, walking, and running moods to default.",
    OnRun = function(self, ply)
        local char = ply:GetCharacter()
        if not char then return end

        char:SetMoodStand(0)
        char:SetMoodWalk(0)
        char:SetMoodRun(0)

        ix.util.Notify("Your mood animations have been reset to default.", ply)
    end
})

ix.command.Add("Surrender", {
    description = "Surrenders — sets your stand, walk, and run moods to hands up.",
    OnCanRun = function(self, ply)
        return IsValid(ply) and ply:GetCharacter() ~= nil
    end,
    OnRun = function(self, ply)
        local char = ply:GetCharacter()
        if not char then return end

        char:SetMoodStand(6)
        char:SetMoodWalk(6)
        char:SetMoodRun(3)
    end
})

ix.util.Include("sh_hooks.lua")
