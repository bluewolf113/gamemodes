local Schema = Schema

function ix.needs.ClearBars()
	local needTbls = ix.needs.GetAll()
	
	for uniqueID, needTbl in pairs(needTbls) do
		if not needTbl.bNoBar then 
			ix.bar.Remove(uniqueID)
		end
	end
end

function ix.needs.SetupBars()
	local character = LocalPlayer():GetCharacter()
	local needTbls = ix.needs.GetAll()
	local orderedTbl = {}
	
	ix.needs.ClearBars()
	
	for uniqueID, needTbl in pairs(needTbls) do
		if ix.needs.CharacterHasNeed(uniqueID, character) and not needTbl.bNoBar then
			table.insert(orderedTbl, needTbl)
		end
	end
	
	table.sort(orderedTbl, function(tbl1, tbl2)
		return tbl1.barPriority and tbl2.barPriority and tbl1.barPriority < tbl2.barPriority
		end)
		
	for k, v in ipairs(orderedTbl) do	
		ix.bar.Add(function()
			local currentNeed = (LocalPlayer():GetCharacter():GetNeed(v.uniqueID) or 0) / 100
			return currentNeed
		end, v.color, nil, v.uniqueID, v.icon)
	end
	
end