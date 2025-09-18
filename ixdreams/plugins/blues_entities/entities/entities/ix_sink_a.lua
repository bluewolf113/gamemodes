AddCSLuaFile()

DEFINE_BASECLASS("base_gmodentity")

ENT.Type = "anim"
ENT.PrintName = "Kitchen Sink"
ENT.Category = "Helix"
ENT.Author = "Nicholas"
ENT.Spawnable = true
ENT.AdminOnly =  true

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
    end
end

function ENT:GetEntityMenu(client)
    local options = {}

    if not self.isOn then
        options["Turn On"] = function()
            self:EmitSound("buttons/lever2.wav", 40)

            -- Delay the start of the looping sound
            timer.Simple(0.8, function()
                if IsValid(self) and not self.isOn then return end

                self.loopingSound = CreateSound(self, "ambient/levels/canals/water_rivulet_loop2.wav")
                if self.loopingSound then
                    self.loopingSound:PlayEx(0.4, 100)
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

            self.isOn = false
        end
    end

    return options
end

function ENT:OnRemove()
    if self.loopingSound then
        self.loopingSound:Stop()
        self.loopingSound = nil
    end
end