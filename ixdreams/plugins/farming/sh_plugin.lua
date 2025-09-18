local PLUGIN = PLUGIN

PLUGIN.name = "Farming"
PLUGIN.author = "Vintage Thief, maxxoft"
PLUGIN.description = "Adds the ability to grow plants."

ix.config.Add("phasetime", 4, "Time a plant needs to get a point to grow to the next phase.", nil, {
    data = {min = 1, max = 3600},
    category = "farming"
})

ix.config.Add("phaserate", 1, "How much a plant gains growth points on timer tick.", nil, {
    data = {min = 1, max = 100},
    category = "farming"
})

ix.config.Add("phaseamount", 10, "How many points a plant needs to get on the next phase.", nil, {
    data = {min = 10, max = 100},
    category = "farming"
})

ix.config.Add("phases", 4, "How many phases a plant needs to fully grow.", nil, {
    data = {min = 2, max = 8},
    category = "farming"
})



-- custom stuff 

ix.command.Add("PlantDebug", {
    description = "Print the growth points and phase of the plant you're looking at.",
    adminOnly = true,
    OnRun = function(self, client)
        local trace = client:GetEyeTrace()
        local ent = trace.Entity

        if not IsValid(ent) or ent:GetClass() ~= "ix_plant" then
            client:Notify("You're not looking at a valid plant.")
            return
        end

        local phase = ent:GetPhase() or 0
        local points = ent:GetGrowthPoints() or 0

        client:ChatPrint(string.format("🌱 Plant Debug:\nPhase: %d\nGrowth Points: %d", phase, points))
    end
})

function PLUGIN:SaveData()
    local data = {}

    for _, ent in ipairs(ents.FindByClass("ix_plant")) do
        data[#data + 1] = {
            pos          = ent:GetPos(),
            phase        = ent.phase or 0,
            growthPoints = ent.growthPoints or 0,
            class        = ent.class,
            seedClass    = ent:GetSeedClass(),
            product      = ent.product,
            name         = ent:GetNetVar("name", "Unnamed Plant"),
            growmodels   = ent.growmodels or {}
        }
    end

    self:SetData(data)
end

function PLUGIN:LoadData()
    local data = self:GetData() or {}

    for _, v in ipairs(data) do
        local ent = ents.Create("ix_plant")
        ent:SetPos(v.pos)
        ent:Spawn()

        ent.phase        = v.phase
        ent.growthPoints = v.growthPoints
        ent.class        = v.seedClass
        ent.product      = v.product
        ent.growmodels   = v.growmodels or {}
        ent:SetNetVar("name", v.name)

        -- Set correct model for current phase
        local idx   = (v.phase or 0) + 1
        local model = ent.growmodels[idx]
        if not model or not util.IsValidModel(model) then
            model = "models/props_lab/plant.mdl"
        end
        ent:SetModel(model)

        if v.phase >= ix.config.Get("phases") then
            ent:EndGrowth()
        end
    end
end
