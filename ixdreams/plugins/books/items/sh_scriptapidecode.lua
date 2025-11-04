ITEM.name = "Decoded Scripta π"
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
			netstream.Start(client, "receiveBook", id, "Pinging host…       Pinging host…       Pinging host…       Pinging host…      Connection lost! \n \nPinging host…       Pinging host…       Pinging host…       Pinging host…      Connection established! \n \nThng \nThng \nHelo? Hello. Secure connection? I hope. Tell al yeur friends abt th new\nand at only 50% of the cost, yours today for\nCider 2: It’s anyone’s gam\nHELP\nou sense the anima of a gr\nNot secure. I’m sharing this channel. It’s getting crossed with other airwaves, but that’s fine. I can live with it. My name used to be Ad\nvote today to secure the fu\nvote today to secure the fu\nvote today to secure the fu\nvote today to secure the fu\npponent Elena Mossman does not know what’s best for Lambd \nght be listening but what I am saying must be heard by someone. I don’t know what it is, but they’re searching for something. They’re prepared to mine the Earth to find it and when it’s theirs, any war you fight will be irrelevant \nLeo Boaz and I approve this mes \nYou will be locked in a cell formed by nothing. It will consume your cities and your nations until you are crippled. Then they’ll poke their heads out from their crypts in the ice and destroy what remain \nPinging host… \nPinging host… \nPinging host… \nConnection lost! \nFRAGMENT DETECTED, ATTEMPTING REPAIR \n1% \n2% \n6% \n56% \n98% \n100% \nLAT 37.5███████████████████████████████████ \nLONG -76.6███████████████████████████████████")
		end
		return false
	end
}
