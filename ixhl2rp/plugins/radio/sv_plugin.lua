
local PLUGIN = PLUGIN

util.AddNetworkString("ixRadio.registerChannel")

function PLUGIN:SaveStationaryRadios()
	local data = {}

	for k, v in ipairs(ents.FindByClass("ix_stationary_radio")) do
		data[#data +1] = {v:GetPos(), v:GetAngles(), v:GetRadioChannel()}
	end

	ix.data.Set("stationaryRadios", data)
end

function PLUGIN:LoadStationaryRadios()
	for k, v in ipairs(ix.data.Get("stationaryRadios") or {}) do
		local ent = ents.Create("ix_stationary_radio")
		ent:SetPos(v[1])
		ent:SetAngles(v[2])
		ent:Spawn()
		ent:SetRadioChannel(v[3])
	end
end
