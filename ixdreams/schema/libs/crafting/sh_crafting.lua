local Schema = Schema

ix.crafting = {} -- Initialize the needs table
ix.crafting.recipes = {}

function Schema:RegisterRecipe(RECIPE)
    if RECIPE and RECIPE.inputs  and RECIPE.outputs then
		local uniqueID = RECIPE.uniqueID
		local workstations = RECIPE.workstations or {"none"}
		
		for _, v in pairs(workstations) do

			ix.crafting.recipes[uniqueID] = RECIPE
			
			local tbl = ix.crafting.recipes[v] or {}		
			
			tbl[uniqueID] = ix.crafting.recipes[uniqueID]
			
			ix.crafting.recipes[v] = tbl
		end

    end
end

function ix.crafting.LoadFromDir(directory)
	local files, folders

	files = file.Find(directory.."/*.lua", "LUA")

	for _, v in ipairs(files) do
		ix.util.Include(directory.."/"..v)
	end
end

function ix.crafting.GetRecipeTable(uniqueID)
	return ix.crafting.recipes[uniqueID]
end

function ix.crafting.GetRecipesByWorkstation(workstation)
	return ix.crafting.recipes[workstation]
end

function ix.crafting.GetInputItemIDs(invID, inputs, inputX, inputY, inputW, inputH)
	local itemIDs = {}
	
	local inputX = inputX or 0
	local inputY = inputY or 0
	
	local inventory = ix.item.inventories[invID]

	for k, v in pairs(inputs) do
		local bItemsFound = false
		for k2, v2 in pairs(v) do
			local count = 0
			
			for x, col in pairs(inventory.slots) do
				for y, item in pairs(col) do
					if count < v2.quantity and item.uniqueID == k2 and x >= inputX and y >= inputY and ((not inputW or x <= (inputW + inputX)) and (not inputH or y <= (inputH + inputY))) then
						table.insert(itemIDs, item:GetID())
						count = count + 1
						bItemsFound = true
					end
				end
				
			end
			
			if count < v2.quantity then
				bItemsFound = false
				break
			end
		end
		
		if bItemsFound then 
			return itemIDs 
		end
	end

	return
end

function ix.crafting.GetAvailableRecipes(inventory, workstation)
	
	local availableRecipes = {}

	local workstation = workstation or "none"
	
	for k, v in pairs(ix.crafting.GetRecipesByWorkstation(workstation)) do
		for k2, v2 in pairs(v.inputs) do
			local bRecipeFound = false
			for k3, v3 in pairs(v2) do
				local count = 0
				local tbl = {}
				local items = inventory:GetItemsByUniqueID(k3)
				
				for _, item in pairs(items) do
					count = count + 1
				end
				
				if count < v3.quantity then
					return
				else
					availableRecipes[k] = true
					bRecipeFound = true
				end
			end
			
			if bRecipeFound then return availableRecipes end
			
		end
	end

	return
end

ix.util.Include("sv_crafting.lua")
ix.util.Include("cl_crafting.lua")

ix.crafting.LoadFromDir(engine.ActiveGamemode().."/schema/libs/crafting/recipes")

ix.config.Add("enableCrafting", false, "Enable crafting.", nil, {
	category = "server"
}, false, true)

-- RECIPE.inputs = {	{	["itemname1"] = {quantity = 1, bNoDelete = false}, 
--							["itemname2"] = {quantity = 2, bNoDelete = false}
--					   },
--					
--						{	["itemname1"] = {quantity = 3, bNoDelete = false}, 
--							["itemname3"] = {quantity = 4, bNoDelete = true}
--					   },
--					}