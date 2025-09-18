
ENT.Type = "anim"
ENT.Author = "SleepyMode"
ENT.PrintName = "Stationary Radio"
ENT.Spawnable = false
ENT.AdminSpawnable = false

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "RadioChannel")
end

function ENT:GetEntityMenu(client)
	local options = {}

	options["Set Frequency"] = function()
		
	end

	return options
end