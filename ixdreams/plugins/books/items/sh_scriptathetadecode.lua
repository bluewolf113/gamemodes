ITEM.name = "Decoded Scripta Θ"
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
			netstream.Start(client, "receiveBook", id, "Record start... \ngest advantage now  is the fact that even they don’t know what they’re looking for. \nThe confidence with which you speak is strong, but greatly misplaced. They may have stolen your physical form, but still you suffer from the mutable perspective of the human animus. We assure you with our greatest emphasis that he does indeed live, just on different shores from us. \nEven if he did, he hasn’t decided to show up. Until he does, I refuse to put any faith in him. We can’t hinge our entire operation on the potentiality of some Jesus wannabe showing up and slaughtering everything in his path. What we need now is precision and tact. \nAnd both of those things we possess in great quantities, most gracious Adeline. But precision and tact cannot conjure success in isolation. You must dig deeper. Risk detection if you must. Death is merely an interval. \nI never understood your kind. You all treat death as a nuisance. For us, it’s the end. Not an end, but the end. If they find out what I’ve been doing, you won’t have anybody on the inside. You’ll be stuck, the world will be doomed and every last transistor of mine will be chucked into the incinerator. Does that sound like an interval to you, elder? \nWe see your point of view. \nThank you. Christ. Do you mind if I ask you something? \nWe are but a reservoir. \nJust what has you so convinced that he’s out there? \nWe see his image. He sits, waiting. He knows that his rest will be brief. Soon a kindling will come and set aflame the embers that drive him. \nOh, right. Nonlinear temporal perception and all that. Yeah, I’ve heard it all before. I trust your wisdom to the end, elder, but I can’t put faith in some religion. I’m a woman of science. \nThe Ravoux assigns labels to the indescribable. For us, the sight of the Vortessence is as fundamental as the ability to smell. Know it to be true that the Freeman lives, and that he has not resigned from his obligation to join forces with us once again. \nWhatever you say. \nRecord stop… \nFRAGMENT DETECTED, ATTEMPTING REPAIR \nFRAGMENT DETECTED, ATTEMPTING REPAIR \n3% \n12% \n45% \n71 \n89 \n100% \nLAT █.█████3144079████████████████████████ \nLONG ███.█████8557230████████████████████████")
		end
		return false
	end
}
