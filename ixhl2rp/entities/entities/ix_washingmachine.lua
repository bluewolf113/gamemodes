AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Washing Machine"
ENT.Category = "Helix"
ENT.Author = "Nicholas"
ENT.Spawnable = true
ENT.AdminOnly = false

function ENT:Initialize()
    self:SetModel("models/props_c17/FurnitureWashingmachine001a.mdl") -- Washing machine model
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
    end
end

AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Washing Machine"
ENT.Category = "Helix"
ENT.Author = "Nicholas"
ENT.Spawnable = true
ENT.AdminOnly = false

ENT.PopulateEntityInfo = true -- Enables tooltip generation

function ENT:Initialize()
    self:SetModel("models/props_c17/FurnitureWashingmachine001a.mdl") -- Washing machine model
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
    end
end

if CLIENT then
    function ENT:OnPopulateEntityInfo(container)
        local nameRow = container:AddRow("name")
        nameRow:SetImportant()
        nameRow:SetText(self.PrintName or "Washing Machine")
        nameRow:SizeToContents()

        local descRow = container:AddRow("description")
        descRow:SetText("A sturdy washing machine, ready to clean outfits.")
        descRow:SizeToContents()

        container:SizeToContents()
    end

    function ENT:GetEntityScreenPosition()
        -- Raise the tooltip origin higher by increasing the Z-axis offset
        local worldPos = self:GetPos() + Vector(0, 0, 100) -- Adjust this value to move tooltip higher
        return worldPos:ToScreen()
    end
end

