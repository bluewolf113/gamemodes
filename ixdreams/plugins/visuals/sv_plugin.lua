
local PLUGIN = PLUGIN

PLUGIN.PositionBuffer  = PLUGIN.PositionBuffer or {}
PLUGIN.ColorProps      = PLUGIN.ColorProps or {}
PLUGIN.ColorPropsLoaded = false

util.AddNetworkString("UpdateColorPropsTable")
util.AddNetworkString("ToggleVisualColorGrading")

function PLUGIN:PostPlayerLoadout(client)
	if (!self.ColorPropsLoaded) then
		self:LoadColorEntities()

		self.ColorPropsLoaded = true
	end

	for _, v in ipairs(ents.GetAll()) do
		if (v.bShowColor) then
			self.ColorProps[v:GetCreationID()] = v
		end
	end

	net.Start("UpdateColorPropsTable")
		net.WriteTable(self.ColorProps)
	net.Send(client)
end

function PLUGIN:SaveData()
	local buffer = {}

	for _,v in ipairs(ents.GetAll()) do
		if (self.visualWhitelist[v:GetClass()] and v.bShowColor) then
			buffer[#buffer + 1] = v:GetPos()
		end
	end

	self:SetData(buffer)
end

function PLUGIN:LoadData()
	self.PositionBuffer = self:GetData()
end

function PLUGIN:LoadColorEntities()
	-- persistence plugin
	local persistence = ix.plugin.list["persistence"]

	for _, v in ipairs(persistence.stored) do
		if (self.visualWhitelist[v:GetClass()]) then
			if (table.HasValue(self.PositionBuffer, v:GetPos())) then
				v.bShowColor = true

				self.ColorProps[v:GetCreationID()] = v
			end
		end
	end

	for _, v in ipairs(ents.FindByClass("ix_item")) do
		if (self.visualWhitelist[v:GetClass()]) then
			if (table.HasValue(self.PositionBuffer, v:GetPos())) then
				v.bShowColor = true

				self.ColorProps[v:GetCreationID()] = v
			end
		end
	end

	for _, v in ipairs(ents.FindByClass("ix_container")) do
		if (self.visualWhitelist[v:GetClass()]) then
			if (table.HasValue(self.PositionBuffer, v:GetPos())) then
				v.bShowColor = true

				self.ColorProps[v:GetCreationID()] = v
			end
		end
	end
end
