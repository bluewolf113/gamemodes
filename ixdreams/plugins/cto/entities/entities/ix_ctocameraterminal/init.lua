include("shared.lua")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_combine/combine_interface001.mdl")
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetSkin(0) -- Start with interface enabled
end

function ENT:UpdateTransmitState()
    return TRANSMIT_ALWAYS
end

function ENT:PhysicsUpdate(physicsObject)
    if not self:IsPlayerHolding() and not self:IsConstrained() then
        physicsObject:SetVelocity(Vector(0, 0, 0))
        physicsObject:Sleep()
    end
end

function ENT:OnOptionSelected(client, option, data)
    local options = self:GetEntityMenu(client)
    if options[option] then
        options[option]() -- Directly execute the selected function
    end
end