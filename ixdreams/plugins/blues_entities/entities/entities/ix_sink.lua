AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Sink"
ENT.Category = "Helix"
ENT.Spawnable = true
ENT.isSource = true

local loopSound = "ambient/water/water_run1.wav"

if SERVER then
    util.AddNetworkString("ixSinkToggle")

    function ENT:Initialize()
        self:SetModel("models/props_c17/furnitureSink001a.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)

        local phys = self:GetPhysicsObject()
        if phys:IsValid() then
            phys:Wake()
        end

        self:SetUseType(SIMPLE_USE)
        self:SetNetVar("isOn", false)
    end

    function ENT:SetOn(state)
        self:SetNetVar("isOn", state)
        self:EmitSound("buttons/lever2.wav", 50)

        timer.Simple(0.9, function()
            if not IsValid(self) then return end

            if state then
                if not self.soundLoop then
                    self.soundLoop = CreateSound(self, loopSound)
                end
                self.soundLoop:PlayEx(0.4, 200) -- lower volume, higher pitch
            else
                if self.soundLoop then
                    self.soundLoop:Stop()
                    self.soundLoop = nil
                end
            end
        end)
    end

    net.Receive("ixSinkToggle", function(_, client)
        local ent = net.ReadEntity()
        if IsValid(ent) and ent:GetClass() == "ix_sink" then
            ent:SetOn(not ent:GetNetVar("isOn", false))
        end
    end)
end

if CLIENT then
    function ENT:GetEntityMenu()
        local options = {}
        local isOn = self:GetNetVar("isOn", false)

        options[isOn and "Turn Off" or "Turn On"] = function()
            net.Start("ixSinkToggle")
                net.WriteEntity(self)
            net.SendToServer()
        end

        return options
    end
end
