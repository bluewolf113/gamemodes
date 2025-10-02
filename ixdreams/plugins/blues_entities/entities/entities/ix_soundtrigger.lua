AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Music Zone"
ENT.Category = "Helix"
ENT.Spawnable = true

if SERVER then
    util.AddNetworkString("ixMusicZonePlay")

    function ENT:Initialize()
        -- Use a visible model (cube, barrel, whatever you like)
        self:SetModel("models/props_c17/oildrum001.mdl")

        -- Make it a physics object so you can grab it with the physgun
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetUseType(SIMPLE_USE)

        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:Wake()
        end

        -- Still act as a trigger
        self:SetTrigger(true)
    end

    function ENT:StartTouch(ent)
        if not IsValid(ent) or not ent:IsPlayer() then return end

        local soundPath = self:GetNWString("MusicPath", "music/hl2_song3.mp3")
        net.Start("ixMusicZonePlay")
            net.WriteString(soundPath)
        net.Send(ent)
    end
end

if CLIENT then
    net.Receive("ixMusicZonePlay", function()
        local path = net.ReadString()
        if path and path ~= "" then
            surface.PlaySound(path)
        end
    end)
end
