local Schema = Schema

ix.needs = {} -- Initialize the needs table
ix.needs.tables = {}

ix.util.Include("sv_needs.lua")
ix.util.Include("cl_needs.lua")

function Schema:RegisterNeed(NEED)
    if NEED and NEED.name then
		local uniqueID = NEED.uniqueID or string.lower(NEED.name)
		
		if not NEED.uniqueID then 
			NEED.uniqueID = uniqueID 
		end
		
        ix.needs.tables[uniqueID] = NEED
		
		ix.char.RegisterVar(uniqueID, {
		field = uniqueID,
		fieldType = ix.type.number,
		default = 0,
		isLocal = true
	})
    end
end

function ix.needs.Get(uniqueID)
	return ix.needs.GetAll()[uniqueID]
end

function ix.needs.GetAll()
	return ix.needs.tables
end

function ix.needs.LoadFromDir(directory)
	local files, folders

	files = file.Find(directory.."/*.lua", "LUA")

	for _, v in ipairs(files) do
		ix.util.Include(directory.."/"..v)
	end
end

function ix.needs.CharacterHasNeed(uniqueID, character)
	local needTbl = ix.needs.Get(uniqueID)
	local bCharacterHasNeed = true
	
	-- whitelist is either true, false, or a table of faction names
	-- true -- default need. can still be toggled by character:SetData(HasNeed_ .. uniqueID)
	-- false -- must be explicitly toggled by character:SetData(HasNeed_ .. uniqueID)
	-- table -- added to characters under any of the included factions
	
	if needTbl.whitelist ~= nil then
		if isstring(needTbl.whitelist) then
			bCharacterHasNeed = ix.faction.indices[character:GetFaction()].name == needTbl.whitelist
		
		elseif istable(needTbl.whitelist) then
		
			for _, faction in pairs(needTbl.whitelist) do
				bCharacterHasNeed = ix.faction.indices[character:GetFaction()].name == faction		
				if bCharacterHasNeed then break end
			end
			
			bCharacterHasNeed = false
		else
			bCharacterHasNeed = needTbl.whitelist
		end
	end
	
	if bCharacterHasNeed then
		bCharacterHasNeed = bCharacterHasNeed and not character:GetData("IgnoreNeed_" .. uniqueID, false)
		
	else
		bCharacterHasNeed = character:GetData("HasNeed_" .. uniqueID, false)	
	end

	return bCharacterHasNeed
end

do
	local charMeta = ix.meta.character

	-- Handle item use to restore needs
	function charMeta:GetNeed(uniqueID)
		if self then	
			-- local id = uniqueID
			-- for k, v in pairs(ix.needs.GetAll()) do
				-- if k == uniqueID or string.find(k, uniqueID) or k == uniqueID or string.find(v.name, uniqueID) then
					-- id = k
				-- end
			-- end
			
			local sFuncGetNeed = "Get" .. uniqueID:gsub("^%l", string.upper)

			return self[sFuncGetNeed](self)
		end
	end
	
-- Handle item use to restore needs
	function charMeta:AddNeed(uniqueID, value)
		if self then
			local sFuncSetNeed = "Set" .. uniqueID:gsub("^%l", string.upper)
			local sFuncGetNeed = "Get" .. uniqueID:gsub("^%l", string.upper)
			
			local currentNeed = self[sFuncGetNeed](self)
			
			if currentNeed then
				self[sFuncSetNeed](self, math.Clamp(currentNeed + value, 0, 100))
			end
		end
	end
	
	-- Handle item use to restore needs
	function charMeta:SetNeed(uniqueID, value)
		if self then
			local sFuncSetNeed = "Set" .. uniqueID:gsub("^%l", string.upper)
			local sFuncGetNeed = "Get" .. uniqueID:gsub("^%l", string.upper)
			
			local currentNeed = self[sFuncGetNeed](self)

			self[sFuncSetNeed](self, math.Clamp(value, 0, 100))
		end
	end
end



ix.command.Add("CharSetNeed", {
    description = "Set the need value of the target character.",
    adminOnly = true,
    arguments = {
		ix.type.player,
		ix.type.string,
		ix.type.number
	},
    OnRun = function(self, client, target, uniqueID, value)
        if not IsValid(target) then return end
		
		local character = target:GetCharacter()
		
		local needName = string.lower(uniqueID)		
		local needValue = character:GetNeed(uniqueID)
		
		if needValue then
			character:SetNeed(needName, value)
		else
			client:ChatPrint("Need '" .. uniqueID .. "' does not exist on the target!")
		end
    end
})

ix.command.Add("CharGetNeed", {
    description = "Get the need value of the target player.",
    adminOnly = true,
    arguments = {
		ix.type.player,
		ix.type.string
	},
    OnRun = function(self, client, target, uniqueID)
        -- if not IsValid(target) then return end
		
		local character = target:GetCharacter()
		
		local needName = string.lower(uniqueID)
		local needValue = character:GetNeed(needName)
		
		if needValue then
			client:ChatPrint(uniqueID .. " value is ".. needValue .. ".")
		else
			client:ChatPrint("Need '" .. uniqueID .. "' does not exist on the target!")
		end
    end
})

ix.needs.LoadFromDir(engine.ActiveGamemode().."/schema/libs/needs/needs")