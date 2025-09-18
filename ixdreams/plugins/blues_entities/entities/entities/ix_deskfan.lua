AddCSLuaFile()

DEFINE_BASECLASS("base_gmodentity")

ENT.Type = "anim"
ENT.PrintName = "Desk Fan"
ENT.Category = "Helix"
ENT.Author = "Nicholas"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.bNoPersist = true

util.AddNetworkString("ixDeskFanToggle")

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "FanOn")
end

if SERVER then
    function ENT:Initialize()
        self:SetModel("models/nita/ph_resortmadness/deskfan.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetUseType(SIMPLE_USE)

        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:Wake()
        end

        self:SetFanOn(false)
        self:PlayFanAnim("idle")
    end

    function ENT:PlayFanAnim(name)
        local seq = self:LookupSequence(name)
        if seq and seq > 0 then
            self:ResetSequence(seq)
        end
    end

    net.Receive("ixDeskFanToggle", function(_, client)
        local ent = net.ReadEntity()
        if not IsValid(ent) or ent:GetPos():DistToSqr(client:GetPos()) > 10000 then return end

        local newState = not ent:GetFanOn()
        ent:SetFanOn(newState)
        ent:EmitSound("buttons/button14.wav", 60)

        if newState then
            ent:PlayFanAnim("on")
        else
            ent:PlayFanAnim("idle")
        end
    end)
end

if CLIENT then
    ENT.PopulateEntityMenu = true -- 🔧 Enables the Helix right-click menu

    function ENT:GetEntityMenu(client)
        local options = {}

        if not self:GetFanOn() then
            options["Turn On"] = function()
                net.Start("ixDeskFanToggle")
                net.WriteEntity(self)
                net.SendToServer()
            end
        else
            options["Turn Off"] = function()
                net.Start("ixDeskFanToggle")
                net.WriteEntity(self)
                net.SendToServer()
            end
        end

        return options
    end
end
