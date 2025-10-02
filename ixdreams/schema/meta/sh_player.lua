
local PLAYER = FindMetaTable("Player")

function PLAYER:IsPolice()
	return self:Team() == FACTION_POLICE
end

--
-- for debug purposes now
function PLAYER:IsCombine()
	return self:GetFaction() == FACTION_MPF or faction == FACTION_OTA or FACTION_POLICE
end

function PLAYER:IsDispatch()
	local name = self:Name()
	local faction = self:Team()
	local bStatus = faction == FACTION_OTA

	if (!bStatus) then
		for k, v in ipairs({ "SCN", "DvL", "SeC" }) do
			if (Schema:IsCombineRank(name, v)) then
				bStatus = true

				break
			end
		end
	end

	return bStatus
end