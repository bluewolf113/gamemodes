function ix.zones.AddZone(name, startPos, endPos, type)
	ix.zones[name] = {startPos = startPos, endPos = endPos, type = type}
end

function ix.zones.ModifyZone(name, startPos, endPos, type)
	local tbl = ix.zones[name]
	
	if not tbl then return end
	
	tbl.startPos = startPos or tbl.startPos
	tbl.endPos = endPos or tbl.endPos
	tbl.type = type or tbl.type
end

function ix.zones.RemoveZone(name)
	if ix.zones[name] then
		ix.zones[name] = nil
	else
		print("RemoveZone: zone '" .. name .. "' does not exist")
	end
end