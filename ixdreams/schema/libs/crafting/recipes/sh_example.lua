local Schema = Schema

RECIPE = {}
RECIPE.time = 1
RECIPE.uniqueID = "example"
RECIPE.workstations = {"workbench", "none"}
-- RECIPE.skills = {["tin"] = 50, ["coo"] = 25}

-- inputs is a table of tables, each of which represents a mutually acceptable combination of input items
-- an indexed inputs table will be mapped to an outputs table with the same index if it exists

-- RECIPE.inputs = {	{	["itemname1"] = {quantity1, bNoDelete = false, data = nil}, 
--							["itemname2"] = {quantity2, bNoDelete = false, data = nil}
--					   },
--					
--						{	["itemname1"] = {quantity3, bNoDelete = false}, 
--							["itemname3"] = {quantity4, bNoDelete = true}
--					   },
--					}
					

RECIPE.inputs = {	{["scrapmetal"] = {quantity = 3}, ["scrapwood"] = {quantity = 2}}, 
					{["scrapplastic"] = {quantity = 3}, ["scrapwood"] = {quantity = 2}}
					}
					
-- the quantity can also be a random number range a-b represented by a table {a, b}
					
RECIPE.outputs = {["emptybox2"] = 1, ["emptycanteen"] = 1}

-- Additional recipe logic, set data on the item based on the input items, etc 
-- function RECIPE:DoRecipe(client, character)

-- end

Schema:RegisterRecipe(RECIPE)