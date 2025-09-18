PLUGIN.name = "Misc changes"
PLUGIN.author = "the stalker guy"
PLUGIN.desc = "Makes changes to several helix settings and such that I don't want players editing"

if (CLIENT) then
	function PLUGIN:CharacterLoaded()
		-- sets options for players that we want them to have
		ix.option.Set("openBags", false, false)


		--hides various settings from the client that dont do anything
		ix.option.stored["openBags"].hidden = function() return true end
	end
end