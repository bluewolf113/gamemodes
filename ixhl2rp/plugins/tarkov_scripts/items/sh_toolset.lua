ITEM.name = "A Set of Tools"
ITEM.description = "A whole lotta' tools that you could do a whole lotta' stuff with."
ITEM.model = Model("models/illusion/eftcontainers/toolset.mdl")
ITEM.category = "Tools"
ITEM.width = 2
ITEM.height = 2
ITEM.items = {"screwdriver", "pliers"}

ITEM.functions.Unpack = {
	OnRun = function(itemTable)
		local client = itemTable.player
		local character = client:GetCharacter()

		for k, v in ipairs(itemTable.items) do
			if (!character:GetInventory():Add(v)) then
				ix.item.Spawn(v, client)
			end
		end
		
		client:EmitSound("ambient/fire/mtov_flame2.wav", 75, math.random(160, 180), 0.35)
	end
}