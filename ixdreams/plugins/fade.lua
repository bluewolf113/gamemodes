local PLUGIN = PLUGIN

PLUGIN.name = "Screen Fade"
PLUGIN.author = ""
PLUGIN.description = "Allows screen fade in and out."

ix.command.Add("PlyFadeOut", {
    description = "Fades player screen, until at R/G/B values.",
    adminOnly = true,
    arguments = {
        ix.type.player,
        ix.type.number,
        bit.bor(ix.type.number, ix.type.optional),
		bit.bor(ix.type.number, ix.type.optional),
		bit.bor(ix.type.number, ix.type.optional),
		bit.bor(ix.type.number, ix.type.optional)
    },
    OnRun = function(self, client, target, duration, r, g, b, a)
        r = r or 0
        g = g or 0
        b = b or 0
        a = a or 255

        target:ScreenFade(SCREENFADE.PURGE, Color(r, g, b, a), 0, 0)
        target:ScreenFade(SCREENFADE.OUT, Color(r, g, b, a), duration, 0)

        timer.Simple(duration, function()
            target:ScreenFade(SCREENFADE.STAYOUT, Color(r, g, b, a), 0, 0)
        end )

        -- ix.util.Notify(string.format("%s faded out %s's screen [%i %i %i %f/%fs]", client:Name(), target:Name(), r, g, b, a, duration), Player:IsAdmin())
	end
})

ix.command.Add("PlyFadeIn", {
    description = "Fades player screen from R/G/B values, until sight is normal.",
    adminOnly = true,
    arguments = {
        ix.type.player,
        ix.type.number,
        bit.bor(ix.type.number, ix.type.optional),
		bit.bor(ix.type.number, ix.type.optional),
		bit.bor(ix.type.number, ix.type.optional),
		bit.bor(ix.type.number, ix.type.optional)
    },
    OnRun = function(self, client, target, duration, r, g, b, a)
        r = r or 0
        g = g or 0
        b = b or 0
        a = a or 255

        target:ScreenFade(SCREENFADE.PURGE, Color(r, g, b, a), 0, 0)
        target:ScreenFade(SCREENFADE.IN, Color(r, g, b, a), duration, 0)

        -- ix.util.Notify(string.format("%s faded in %s's screen [%i %i %i %f/%fs]", client:Name(), target:Name(), r, g, b, a, duration))
	end
})

ix.command.Add("PlyUnfade", {
    description = "Removes any fade effects from player.",
    adminOnly = true,
    arguments = {
        ix.type.player
    },
    OnRun = function(self, client, target)
        client:ScreenFade(SCREENFADE.PURGE, color_black, 0, 0)

        -- ix.util.Notify(string.format("%s unfaded %s's screen", client:Name(), target:Name()))
	end
})

ix.command.Add("ServerFadeOut", {
    description = "Fades the server, until everyone's screens at R/G/B value.",
    adminOnly = true,
    arguments = {
        ix.type.number,
        bit.bor(ix.type.number, ix.type.optional),
		bit.bor(ix.type.number, ix.type.optional),
		bit.bor(ix.type.number, ix.type.optional),
		bit.bor(ix.type.number, ix.type.optional)
    },
    OnRun = function(self, client, duration, r, g, b, a)
        r = r or 0
		g = g or 0
		b = b or 0
		a = a or 255

        for k, target in pairs(player.GetAll()) do
            target:ScreenFade(SCREENFADE.PURGE, Color(r, g, b, a), 0, 0)
            target:ScreenFade(SCREENFADE.OUT, Color(r, g, b, a), duration, 0)
        end

        timer.Simple(duration, function()
            for k, target in pairs(player.GetAll()) do
                target:ScreenFade(SCREENFADE.STAYOUT, Color(r, g, b, a), 0, 0)
            end
        end )

        -- ix.util.Notify(string.format("%s faded out everyone's screen [%i %i %i %f/%fs]", client:Name(), r, g, b, a, duration))
    end
})

ix.command.Add("ServerFadeIn", {
    description = "Fades everyone's screen from R/G/B values, until sight is normal.",
    adminOnly = true,
    arguments = {
        ix.type.number,
        bit.bor(ix.type.number, ix.type.optional),
		bit.bor(ix.type.number, ix.type.optional),
		bit.bor(ix.type.number, ix.type.optional),
		bit.bor(ix.type.number, ix.type.optional)
    },
    OnRun = function(self, client, duration, r, g, b, a)
        r = r or 0
		g = g or 0
		b = b or 0
		a = a or 255

        for k, target in pairs(player.GetAll()) do
            target:ScreenFade(SCREENFADE.PURGE, Color(r, g, b, a), 0, 0)
            target:ScreenFade(SCREENFADE.IN, Color(r, g, b, a), duration, 0)
        end

        -- ix.util.Notify(string.format("%s faded in everyone's screen [%i %i %i %f/%fs]", client:Name(), r, g, b, a, duration))
	end
})

ix.command.Add("ServerUnfade", {
    description = "Removes any fade effects from all players.",
    adminOnly = true,
    OnRun = function(self, client)

        for k, target in pairs(player.GetAll()) do
            target:ScreenFade(SCREENFADE.PURGE, color_black, 0, 0)
        end

        -- ix.util.Notify(string.format("%s unfaded everyone's screens.", client:Name()))
	end
})