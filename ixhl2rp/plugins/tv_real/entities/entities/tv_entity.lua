DEFINE_BASECLASS("base_gmodentity")

ENT.Type = "anim"
ENT.PrintName = "Television"
ENT.Author = "Your Name"
ENT.Category = "Custom"
ENT.Spawnable = true
ENT.AdminSpawnable = true

-- Channel name → sound path
ENT.Channels = {
    Broadcast = "ambient/alarms/city_siren_loop2.wav",
    Weather   = "ambient/alarms/manhack_alert_pass1.wav",
    Static    = "ambient/machines/television_static.wav",
    News      = "ambient/radio/news_broadcast.wav"
}

function ENT:Initialize()
    if SERVER then
        -- Set the TV model here. You can use any model you prefer.
        self:SetModel("models/props_c17/oildrum001.mdl")
        self:SetSkin(1) -- Off state (skin 1 means "off")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        
        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:Wake()
        end

        -- Default channel and sound variables
        self.CurrentChannel = "Broadcast"
        self.SoundLoop = nil
    end
end

-- This function is used by Helix (or similar) to build an entity interaction menu.
function ENT:GetEntityMenu(client)
    local options = {}

    if self:GetSkin() == 1 then
        options["Turn On"] = function()
            self:SetSkin(0)
            self:EmitSound("buttons/combine_button1.wav", 60)
            self:StartSoundLoop(self.Channels[self.CurrentChannel])
        end
        return options
    else
        options["Turn Off"] = function()
            self:SetSkin(1)
            self:EmitSound("buttons/combine_button2.wav", 60)
            self:StopSoundLoop()
        end

        -- For each channel option, create a switch option
        for channelName, soundPath in pairs(self.Channels) do
            options["Switch to " .. channelName] = function()
                self:StopSoundLoop() -- Stop current sound before switching.
                self.CurrentChannel = channelName
                self:EmitSound("buttons/button14.wav", 60)
                self:StartSoundLoop(soundPath)
            end
        end
    end

    return options
end

-- Start playing the looping sound for the current channel.
function ENT:StartSoundLoop(path)
    if SERVER then
        if not path then return end

        -- If there's an existing sound, stop it.
        if self.SoundLoop then
            self.SoundLoop:Stop()
        end
        
        self.SoundLoop = CreateSound(self, path)
        if self.SoundLoop then
            self.SoundLoop:EnableLooping(true)   -- Ensure the sound loops continuously.
            self.SoundLoop:PlayEx(0.3, 100)        -- Adjust volume (0.3) and pitch (100) as desired.
        end
    end
end

-- Stop any currently playing sound.
function ENT:StopSoundLoop()
    if SERVER and self.SoundLoop then
        self.SoundLoop:Stop()
        self.SoundLoop = nil
    end
end

function ENT:OnRemove()
    self:StopSoundLoop()
end