
local PLUGIN = PLUGIN

function PLUGIN:SaveData()
	self:SaveStationaryRadios()
end

function PLUGIN:LoadData()
	self:LoadStationaryRadios()
end