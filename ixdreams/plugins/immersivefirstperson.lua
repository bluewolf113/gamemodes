local PLUGIN = PLUGIN

PLUGIN.name = "Immersive First Person"
PLUGIN.author = "Blue & Copilot"
PLUGIN.description = "Intergration of spy's IFP plugin."

ix.lang.AddTable("english", {
	optUseIfp = "Toggle Immersive 1st Person",
	optViewsmooth = "Immersive 1st Person view smoothing",
    optIFPCross = "Immersive 1st Person Crosshair"
})

if CLIENT then
    ix.option.Add("useIfp", ix.type.bool, false, {
        category = "View",
        description = "Toggles a full body first person.",
        OnChanged = function(oldValue, newValue)
            RunConsoleCommand("iv_status", newValue and "1" or "0")
        end
    })

    ix.option.Add("IFPCross", ix.type.bool, false, {
        category = "View",
        description = "Toggles the Immersive First Person crosshair.",
        OnChanged = function(oldValue, newValue)
            RunConsoleCommand("iv_crosshair", newValue and "1" or "0")
        end
    })

    ix.option.Add("Viewsmooth", ix.type.number, 0.4, {
		category = "View", min = 0.2, max = 0.8, decimals = 1,
        OnChanged = function(oldVal, newVal)
            RunConsoleCommand("iv_viewsmooth", tostring(newVal))
        end
    })
end