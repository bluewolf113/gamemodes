AddCSLuaFile()

ENT.Type = "anim"
ENT.Author = "Vintage Thief, maxxoft"
ENT.PrintName = "Plant"
ENT.Description = "A planted seedling"
ENT.Spawnable = false
ENT.PopulateEntityInfo = true

ENT.growmodels = {}

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "Phase")
end

if SERVER then
    util.AddNetworkString("ixHarvestPlant")
    util.AddNetworkString("ixPullPlant")

    function ENT:Initialize()
        local pos = self:GetPos()

        self:SetMoveType(MOVETYPE_NONE)
        self:SetUseType(SIMPLE_USE)
        self:SetSolid(SOLID_BBOX)
        self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
        self:SetCollisionBounds(Vector(-3, -3, 0), Vector(3, 3, 8))

        self.growthPoints = self.growthPoints or 0
        self.phase = self.phase or 0
        self:SetPhase(self.phase)

        local mdl = self.growmodels[1]
        if not mdl or not util.IsValidModel(mdl) then
            mdl = "models/props_lab/plant.mdl"
        end
        self:SetModel(mdl)

        local timerName = "phasetimer_" .. self:EntIndex()
        timer.Create(timerName, ix.config.Get("phasetime"), 0, function()
            if not IsValid(self) then
                timer.Remove(timerName)
                return
            end

            local rate = ix.config.Get("phaserate")
            local amount = ix.config.Get("phaseamount")
            local maxPh = ix.config.Get("phases")

            self.growthPoints = (self.growthPoints or 0) + rate

            if self.growthPoints >= amount and self.phase < maxPh then
                self.phase = self.phase + 1
                self:SetPhase(self.phase)
                self.growthPoints = 0

                local nextMdl = self.growmodels[self.phase + 1]
                if not nextMdl or not util.IsValidModel(nextMdl) then
                    nextMdl = self:GetModel()
                end
                self:SetModel(nextMdl)
            end

            if self.phase >= maxPh then
                self:EndGrowth()
            end
        end)
    end

    function ENT:EndGrowth()
        self.grown = true
        self:SetNetVar("grown", true)
        timer.Remove("phasetimer_" .. self:EntIndex())

        local final = self.growmodels[ix.config.Get("phases") + 1]
        if not final or not util.IsValidModel(final) then
            final = self:GetModel()
        end
        self:SetModel(final)
    end

    function ENT:SetClass(class)
        self.class = class
    end

    function ENT:GetSeedClass()
        return self.class
    end

    function ENT:SetProduct(itemID)
        self.product = itemID
    end

    function ENT:SetPlantName(name)
        self:SetNetVar("name", name or "Unnamed Plant")
    end

    function ENT:GetPhase()
        return self:GetNW2Int("Phase", 0)
    end

    function ENT:GetGrowthPoints()
        return self.growthPoints or 0
    end

    function ENT:SetGrowthPoints(iPoints)
        self.growthPoints = iPoints
    end

    function ENT:OnRemove()
        timer.Remove("phasetimer_" .. self:EntIndex())
    end

    net.Receive("ixHarvestPlant", function(_, ply)
        local ent = net.ReadEntity()
        if not IsValid(ply) or not ply:IsPlayer() then return end
        if not IsValid(ent) or ent:GetClass() ~= "ix_plant" or not ent.grown then return end

        if ent.product then
            ix.item.Spawn(ent.product, ent:GetPos() + Vector(0, 0, 2))
        end

        if ent:GetSeedClass() and math.random() < 0.5 then
            ix.item.Spawn(ent:GetSeedClass(), ent:GetPos() + Vector(0, 0, 3))
        end

        ply:Notify("You harvest the plant.")
        ent:Remove()
    end)

    net.Receive("ixPullPlant", function(_, ply)
        local ent = net.ReadEntity()
        if not IsValid(ply) or not ply:IsPlayer() then return end
        if not IsValid(ent) or ent:GetClass() ~= "ix_plant" then return end

        local char = ply:GetCharacter()
        local seedClass = ent:GetSeedClass()

        if seedClass and char then
            char:GetInventory():Add(seedClass, 1)
            ply:Notify("You pulled the plant and recovered its seed.")
        else
            ply:Notify("You pull the plant but recover nothing.")
        end

        ent:Remove()
    end)
end

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
    end

    function ENT:OnPopulateEntityInfo(tooltip)
        local name = self:GetNetVar("name", "Unnamed Plant")
        local desc = self:GetNetVar("grown", false)
                     and "The plant is fully grown."
                     or "The plant is still growing."

        local row = tooltip:AddRow("name")
        row:SetText(name)
        row:SetImportant()
        row:SizeToContents()

        local info = tooltip:AddRow("desc")
        info:SetText(desc)
        info:SizeToContents()
    end

    function ENT:GetEntityMenu(ply)
        local options = {}

        options["Inspect"] = function()
            local phase = self:GetPhase()
            local messages = {
                [0] = "This seedling has barely sprouted.",
                [1] = "Small leaves are emerging.",
                [2] = "It's halfway to maturity.",
                [3] = "The plant appears almost ripe.",
            }
            ply:ChatPrint(messages[phase] or "You inspect the plant.")
        end

        if self:GetNetVar("grown", false) then
            options["Harvest Plant"] = function()
                net.Start("ixHarvestPlant")
                    net.WriteEntity(self)
                net.SendToServer()
            end
        end

        options["Pull Plant"] = function()
            net.Start("ixPullPlant")
                net.WriteEntity(self)
            net.SendToServer()
        end

        return options
    end
end
