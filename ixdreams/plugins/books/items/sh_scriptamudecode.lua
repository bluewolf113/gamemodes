ITEM.name = "Decoded Scripta μ"
ITEM.model = "models/props_hla/combine/memory2.mdl"
ITEM.category = "Scripta"
ITEM.width = 3
ITEM.height = 2
ITEM.description = "34289785930598374093875325572984305743890136490375093478930653280947389056321408932758093261489320752385462389047328956237548932045732805963289407325893265380924798563104983274"
ITEM.price = 0

ITEM.functions.use = {
	name = "Open",
	icon = "icon16/pencil.png",
	OnRun = function(item)
		local client = item.player
		local id = item:GetID()
		if (id) then
			netstream.Start(client, "receiveBook", id, "Initializing... \n1/20/67, 0900 hrs \nCallsign input \nDS-0.0 \nSecure password input \n********************* \nPrimary objective: Reacquire asset ‘Dispersion Engine’, secure area for extraction \nSecondary objective: Retire or reassign extant G4 assets \nTertiary objective: Weaken insurgent target ‘Lambda’ \nInsertion zone: 34km south of ‘Kytheria’ insurgent territory, Sector 1 \nAdditional: Location of primary target is unknown, may necessitate research or investigation. Last known location of relevant information, Blacksite Sec.1-4461, coordinates enclosed. Maintain discretion. \nFRAGMENT DETECTED, ATTEMPTING REPAIR \n4% \n9% \n13% \n47% \n78% \n100% \nLAT █.█0043███████████████████████████████ \nLONG ███.█2412███████████████████████████████")
		end
		return false
	end
}
