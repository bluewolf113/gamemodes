AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Music Zone"
ENT.Category = "Helix"
ENT.Spawnable = true

if SERVER then
    util.AddNetworkString("ixMusicZonePlay")
    util.AddNetworkString("ixSoundTriggerUpdate")

    function ENT:Initialize()
        local mdl = self:GetNetVar("model", "models/hunter/plates/plate2x2.mdl")
        self:SetModel(mdl)

        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetUseType(SIMPLE_USE)
        self:SetTrigger(true)

        local phys = self:GetPhysicsObject()
        if IsValid(phys) then phys:Wake() end
    end

    function ENT:StartTouch(ent)
        if not IsValid(ent) or not ent:IsPlayer() then return end

        local soundPath = self:GetNWString("MusicPath", "common/bugreporter_failed.wav")
        net.Start("ixMusicZonePlay")
            net.WriteString(soundPath)
        net.Send(ent)
    end

    net.Receive("ixSoundTriggerUpdate", function(_, ply)
        if not ply:IsAdmin() then return end

        local ent = net.ReadEntity()
        local key = net.ReadString()
        local val = net.ReadString()

        if not IsValid(ent) or ent:GetClass() ~= "ix_soundtrigger" then return end

        ent:SetNetVar(key, val)

        if key == "model" then
            ent:SetModel(val)
            ent:PhysicsInit(SOLID_VPHYSICS)
            local phys = ent:GetPhysicsObject()
            if IsValid(phys) then phys:Wake() end
        end
    end)
end

if CLIENT then
    net.Receive("ixMusicZonePlay", function()
        local path = net.ReadString()
        if path and path ~= "" then
            surface.PlaySound(path)
        end
    end)

    function ENT:Draw()
        self:DrawModel()
    end
end

properties.Add("ix_set_musicpath", {
    MenuLabel = "Set Music Path",
    Order     = 3,
    MenuIcon  = "icon16/music.png",

    Filter = function(self, ent, ply)
        return IsValid(ent)
           and ent:GetClass() == "ix_soundtrigger"
           and ply:IsAdmin()
    end,

    Action = function(self, ent)
        Derma_StringRequest(
            "Set Music Path",
            "Enter sound file path (e.g. music/hl2_song3.mp3):",
            ent:GetNWString("MusicPath", ""),
            function(input)
                net.Start("ixSoundTriggerUpdate")
                    net.WriteEntity(ent)
                    net.WriteString("MusicPath")
                    net.WriteString(input)
                net.SendToServer()
            end
        )
    end
})


properties.Add("ix_set_model", {
    MenuLabel = "Set Model",
    Order     = 1,
    MenuIcon  = "icon16/brick.png",

    Filter = function(self, ent, ply)
        return IsValid(ent)
           and ent:GetClass() == "ix_soundtrigger"
           and ply:IsAdmin()
    end,

    Action = function(self, ent)
        Derma_StringRequest(
            "Set Model", "Enter model path:",
            ent:GetNetVar("model", ""),
            function(input)
                net.Start("ixSoundTriggerUpdate")
                    net.WriteEntity(ent)
                    net.WriteString("model")
                    net.WriteString(input)
                net.SendToServer()
            end
        )
    end
})

properties.Add("ix_toggle_visibility", {
    MenuLabel = "Toggle Visibility",
    Order     = 2,
    MenuIcon  = "icon16/contrast.png",

    Filter = function(self, ent, ply)
        return IsValid(ent)
           and ent:GetClass() == "ix_soundtrigger"
           and ply:IsAdmin()
    end,

    Action = function(self, ent)
        local currentColor = ent:GetColor()
        local isInvisible = currentColor.a == 0

        if isInvisible then
            ent:SetColor(Color(255, 255, 255, 255))
            ent:SetRenderMode(RENDERMODE_NORMAL)
        else
            ent:SetColor(Color(255, 255, 255, 0))
            ent:SetRenderMode(RENDERMODE_TRANSALPHA)
        end
    end
})