AddCSLuaFile()

DEFINE_BASECLASS("base_gmodentity")

ENT.Type        = "anim"
ENT.PrintName   = "Sink"
ENT.Category    = "Helix"
ENT.Author      = "Nicholas"
ENT.Spawnable   = true
ENT.AdminOnly   = true
ENT.bNoPersist  = true -- Prevents it from saving like a source does

-- Liquid-storage compatibility (matches ix_liquidsource)
function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "DisplayName")
    self:NetworkVar("String", 1, "StoredModel")
    self:NetworkVar("String", 2, "Liquid")

    self:NetworkVar("Int", 0, "MaxVolume")
    self:NetworkVar("Int", 1, "CurVolume")

    self:NetworkVar("Bool", 0, "IsInfinite")
    self:NetworkVar("Bool", 1, "ShouldShowTooltip")
end

if SERVER then
    function ENT:Initialize()
        self:SetModel("models/props_c17/FurnitureSink001a.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)

        local phys = self:GetPhysicsObject()
        if IsValid(phys) then phys:Wake() end

        self.isOn = false
        self.loopingSound = nil

        -- Default liquid state
        self:SetStoredModel(self:GetModel())
        self:SetDisplayName("Water Sink")
        self:SetLiquid("water") -- You had "whiskey" before, changed back to "water"
        self:SetMaxVolume(1000)
        self:SetCurVolume(1000)
        self:SetIsInfinite(true)
        self:SetShouldShowTooltip(true)
    end

    function ENT:OnRemove()
        if self.loopingSound then
            self.loopingSound:Stop()
            self.loopingSound = nil
        end

        if ix.liquids and ix.liquids.UnregisterSource then
            ix.liquids.UnregisterSource(self)
        end
    end
end

-- Shared / Client Menu Logic
function ENT:GetEntityMenu(client)
    local options = {}

    if not self.isOn then
        options["Turn On"] = function()
            self:EmitSound("buttons/lever2.wav", 40)

            timer.Simple(0.8, function()
                if not IsValid(self) or self.isOn then return end

                self.loopingSound = CreateSound(self, "ambient/levels/canals/water_rivulet_loop2.wav")
                if self.loopingSound then
                    self.loopingSound:PlayEx(0.4, 100)
                end

                if ix.liquids and ix.liquids.RegisterSource then
                    ix.liquids.RegisterSource(self)
                end
            end)

            self.isOn = true
        end
    else
        options["Turn Off"] = function()
            self:EmitSound("buttons/lever2.wav", 40)

            if self.loopingSound then
                self.loopingSound:Stop()
                self.loopingSound = nil
            end

            if ix.liquids and ix.liquids.UnregisterSource then
                ix.liquids.UnregisterSource(self)
            end

            self.isOn = false
        end
    end

    return options
end

if CLIENT then
    function ENT:Think()
        self:SetNextClientThink(CurTime() + 0.25)
        return true
    end

    function ENT:Draw()
        self:DrawModel()
    end

    -- Tooltip Info (trimmed from ix_liquidsource)
    ENT.PopulateEntityInfo = true
    function ENT:OnPopulateEntityInfo(container)
        if not self:GetShouldShowTooltip() then return end

        local name = container:AddRow("name")
        name:SetImportant()
        name:SetText(self:GetDisplayName())
        name:SizeToContents()

        local liquidData = ix.liquids.Get(self:GetLiquid())
        if not liquidData then return end

        local data = container:AddRow("data")

        if self:GetIsInfinite() then
            data:SetText("Contains " .. liquidData:GetName())
        else
            local vol = self:GetCurVolume()
            local maxVol = self:GetMaxVolume()
            data:SetText(
                "Capacity: " .. ix.liquids.ConvertUnit(maxVol) .. "\n" ..
                (vol > 0 and ("Current: " .. ix.liquids.ConvertUnit(vol)) or "Empty\n") ..
                "Contains " .. liquidData:GetName()
            )
        end

        data:SetFont("ixGenericFont")
        data:SizeToContents()
    end
end
