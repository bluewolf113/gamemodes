local PLUGIN = PLUGIN

PLUGIN.name = "Cutscene"
PLUGIN.author = "jb"
PLUGIN.description = "Opens a webpage"

if CLIENT then
    -- Must be wrapped in quotes
    concommand.Add( "lua_runcs", function(ply, cmd, args)
        cutscene = vgui.Create("DHTML")
        cutscene:SetSize(ScrW(), ScrH())
        cutscene:SetPos(0, 0)
        cutscene:OpenURL( table.concat( args ) )
    end)

    concommand.Add( "lua_stopcs", function()
        if IsValid(cutscene) then
            cutscene:Remove()
        end
    end)
end

ix.command.Add("PlayCutscene", {
	alias = "exec",
	description = "Plays a cutscene for a single player",
	superAdminOnly = true,
	arguments = {
		ix.type.player,
		ix.type.string
	},
	OnRun = function(self, client, target, url)
		target:ScreenFade(SCREENFADE.OUT, color_black, 1, 10)
        timer.Simple( 1, function()
            target:ConCommand( "lua_runcs " .. "\"" .. url .. "\"" )
        end )

		return true
	end
})

ix.command.Add("PlayCutsceneAll", {
	description = "Plays a cutscene for all players",
	adminOnly = true,
    arguments = {
		ix.type.string
	},
	OnRun = function (self, client, url)
        for _, ply in ipairs( player.GetAll() ) do
            ply:ScreenFade(SCREENFADE.OUT, color_black, 1, 10)
            timer.Simple( 1, function()
                ply:ConCommand( "lua_runcs " .. "\"" .. url .. "\"" )
            end )
        end
	end
})

ix.command.Add("StopCutsceneAll", {
	description = "Stops a cutscene for all players",
	adminOnly = true,
	OnRun = function (self, client)
		for _, ply in ipairs( player.GetAll() ) do
            ply:ConCommand( "lua_stopcs" )
            ply:ScreenFade(SCREENFADE.IN, color_black, 3, 1)
		end
	end
})

ix.command.Add("StopCutscene", {
	description = "Stops a cutscene a target",
	adminOnly = true,
	OnRun = function(self, client, target, url)
		target:ConCommand( "lua_stopcs" )
        target:ScreenFade(SCREENFADE.IN, color_black, 3, 1)

		return true
	end
})