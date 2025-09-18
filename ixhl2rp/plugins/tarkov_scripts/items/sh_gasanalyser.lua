ITEM.name = "Gas Analyser"
ITEM.model = Model("models/illusion/eftcontainers/gasanalyser.mdl")
ITEM.description = "Measuring device for determining the quantitative composition of gas mixtures. Has a very wide range of applications - in environmental protection, internal combustion engines, managment systems, and medicine."
ITEM.category = "Junk"
ITEM.width = 1
ITEM.height = 2
ITEM.items = {"circuitboard", "circuitboard", "wires"}

ITEM.functions.Scrap = {
	icon = "icon16/cog.png",
	OnRun = function(itemTable)
		local client = itemTable.player
		local character = client:GetCharacter()

		for k, v in ipairs(itemTable.items) do
			if (!character:GetInventory():Add(v)) then
				ix.item.Spawn(v, client)
			end
		end
		
		client:EmitSound("ambient/fire/mtov_flame2.wav", 75, math.random(160, 180), 0.35)
	end,
	OnCanRun = function(itemTable)
		for _, v in pairs(ents.FindByClass("ix_station_workbench")) do
			if (client:GetPos():DistToSqr(v:GetPos()) < 100 * 100) then
				return true
			end
		end
		
		return false, "You need to be near a workbench."
	end
}

ITEM.iconCam = {
	pos = Vector(1.5, 0, 200),
	ang = Angle(90, 0, 0),
	fov = 2.8562716457617,
}

