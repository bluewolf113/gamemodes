AddCSLuaFile()

DEFINE_BASECLASS("base_gmodentity")

ENT.Type = "anim"
ENT.PrintName = "MMR Terminal"
ENT.Author = "Blue and Copilot"
ENT.Category = "HL2 RP"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.UsableInVehicle = true

if SERVER then
    function ENT:Initialize()
        self:SetModel("models/props_combine/combine_binocular01.mdl")
        self:SetSolid(SOLID_VPHYSICS)
        self:SetUseType(SIMPLE_USE)
        self:PhysicsInit(SOLID_VPHYSICS)

        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:Wake()
        end
    end

    function ENT:Use(client)
        if IsValid(client) and client:IsPlayer() then
            ix.entityInteract.OpenMenu(client, self)
        end
    end
end

--change mmr messages, these are placeholdsers mostly

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
    end

	function ENT:GetEntityMenu(client)
        local options = {}

        options["Receive MMR"] = function()
            local mmrMessages = {
                "You feel something shift in you. Something in the core of you. You cannot yet place it.",
                "A mysterious energy fills you, unsettling and yet strangely familiar.",
                "A deep resonance echoes within, stirring emotions you thought long forgotten.",
                "A sudden clarity washes over you—an echo of memories from beyond."
            }

            client:ChatPrint(mmrMessages[math.random(#mmrMessages)])
        end

        return options
	end
end