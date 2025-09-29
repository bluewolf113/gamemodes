
local PLAYER = FindMetaTable("Player")

function PLAYER:IsPolice()
	return self:Team() == FACTION_POLICE
end

--
-- for debug purposes now
function playerMeta:IsCombine()
	local faction = self:Team()
	return faction == FACTION_MPF or faction == FACTION_OTA or FACTION_POLICE
end

function playerMeta:IsDispatch()
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