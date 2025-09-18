AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Hint"
ENT.Category = "Helix"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.PhysgunDisable = false
-- ENT.bNoPersist = true

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "Description")
	self:NetworkVar("Int", 1, "DrawRange")
	self:NetworkVar("Bool", 1, "Enabled")
end

function ENT:Initialize()
	if SERVER then
		self:SetDescription(self:GetDescription() ~= nil and self:GetDescription() ~= "" and self:GetDescription() or "This is a hint entity.")
		self:SetDrawRange(self:GetDrawRange() ~= nil and self:GetDrawRange() ~= 0 and self:GetDrawRange() or 200^2)
		self:SetEnabled(self:GetEnabled() ~= nil and self:GetEnabled() or true)

		self:SetModel("models/hunter/plates/plate.mdl")
		self:SetSolid(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:DrawShadow(false)
		self:SetNoDraw(true)

		local phys = self:GetPhysicsObject()
		
		if IsValid(phys) then
			phys:Wake()
		end
		
		-- net.Start("ixHintEntityCreated")
			-- net.WriteEntity()
		-- net.Send(player.GetAll())
	end
end

if SERVER then
    util.AddNetworkString("ixSetHintDescription")
	util.AddNetworkString("ixSetHintDrawRange")
	util.AddNetworkString("ixSetHintEnabled")
	util.AddNetworkString("ixHintEntityCreated")
	
	net.Receive("ixSetHintDescription", function()
		local entity = net.ReadEntity()
		local sDescription = net.ReadString()

		if IsValid(entity) and entity:GetClass() == "ix_hint" then
			entity:SetDescription(sDescription)
		end
	end)
	
	net.Receive("ixSetHintDrawRange", function()
		local entity = net.ReadEntity()
		local range = net.ReadInt(32)

		if IsValid(entity) and entity:GetClass() == "ix_hint" then
			entity:SetDrawRange(range)
		end
	end)
	
	net.Receive("ixSetHintEnabled", function()
		local entity = net.ReadEntity()
		local enabled = net.ReadBool()

		if IsValid(entity) and entity:GetClass() == "ix_hint" then
			entity:SetEnabled(enabled)
		end
	end)

    function ENT:Use(activator, caller)
        -- Placeholder for use interaction
    end
end

if CLIENT then
	function ENT:Initialize()
		local ply = LocalPlayer()

		if not ply then return end

		ix.hints.AddHint(self)
	end

	function ENT:Draw()
		local player = LocalPlayer()
		
		if player:GetMoveType() == MOVETYPE_NOCLIP then
			self:DrawModel()
		end
	end
	
	function ENT:OnRemove()
		ix.hints.RemoveHint(self)
	end
	
	-- net.Receive("ixHintEntityCreated", function()
		
		-- local ply = LocalPlayer()
		-- local ent = net.ReadEntity()
		
		-- if not ply or not ent then return end

		-- ix.hints.AddHint(ent)
	-- end)
end

properties.Add("set_hint_description", {
	MenuLabel = "Set Description",
	Order = 2,
	MenuIcon = "icon16/application_form_edit.png",

	Filter = function(self, ent, ply)
		if not IsValid(ent) or ent:GetClass() ~= "ix_hint" then return false end
		if not ply:IsAdmin() then return false end
		return true
	end,

	Action = function(self, ent)
		Derma_StringRequest("Set Description", "Enter description:", ent:GetDescription(), function(description)

			net.Start("ixSetHintDescription")
			net.WriteEntity(ent)
			net.WriteString(description)
			net.SendToServer()
			
			if ent.panel then
				ent.panel:SetText(description)
				ent.panel:SizeToContents()
			end
			
		end)
	end
})

properties.Add("set_hint_draw_range", {
	MenuLabel = "Set Draw Range",
	Order = 3,
	MenuIcon = "icon16/application_form_edit.png",

	Filter = function(self, ent, ply)
		if not IsValid(ent) or ent:GetClass() ~= "ix_hint" then return false end
		if not ply:IsAdmin() then return false end
		return true
	end,

	Action = function(self, ent)
		Derma_StringRequest("Set Draw Range", "Enter distance (integer):", tostring(ent:GetDrawRange()), function(text)
			net.Start("ixSetHintDrawRange")
			net.WriteEntity(ent)
			net.WriteInt(tonumber(text), 32)
			net.SendToServer()
		end)
	end
})

properties.Add("set_hint_enabled", {
	MenuLabel = "Enable",
	Order = 1,
	MenuIcon = "icon16/brick.png",

	Filter = function(self, ent, ply)
		if not IsValid(ent) or ent:GetClass() ~= "ix_hint" then return false end
		if not ply:IsAdmin() then return false end
		return true
	end,

	Action = function(self, ent)
	
	end,
	
	MenuOpen = function(self, option, ent, tr)

	local submenu = option:AddSubMenu()
	local trueOption = submenu:AddOption("True", function()                 
		net.Start("ixSetHintEnabled")
			net.WriteEntity(ent)
			net.WriteBool(true)
		net.SendToServer()
		end)
		
	local falseOption = submenu:AddOption("False",function()                 
		net.Start("ixSetHintEnabled")
			net.WriteEntity(ent)
			net.WriteBool(false)
		net.SendToServer()
		end)

	-- Set the current selection as checked
	local current = ent:GetEnabled()
	if (current) then
		trueOption:SetChecked(true)
	else
		falseOption:SetChecked(true)
	end
end
})

