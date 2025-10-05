PLUGIN.injuries.fever = {
    -- no condition, must be applied manually
    enter = function(ply)
        ply:Notify("You feel feverish...")
        ply:EmitSound("ambient/fire/fire_small_loop1.wav", 60, 50, 0.4)
        if CLIENT and ply == LocalPlayer() then
            hook.Add("RenderScreenspaceEffects", "ixFeverContrast", function()
                local tab = {}
                tab["$pp_colour_contrast"] = 2
                DrawColorModify(tab)
            end)
        end
    end,
    exit = function(ply)
        ply:Notify("Your fever breaks.")
        ply:StopSound("ambient/fire/fire_small_loop1.wav")
        if CLIENT and ply == LocalPlayer() then
            hook.Remove("RenderScreenspaceEffects", "ixFeverContrast")
        end
    end
}
