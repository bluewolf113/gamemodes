PLUGIN.injuries.nausea = {
    -- no condition, must be applied manually
    enter = function(ply)
        ply:Notify("You feel nauseous...")

        if CLIENT and ply == LocalPlayer() then
            -- Green tint overlay
            hook.Add("RenderScreenspaceEffects", "ixNauseaTint", function()
                local tab = {}
                tab[ "$pp_colour_addr" ] = 0
                tab[ "$pp_colour_addg" ] = 0.05
                tab[ "$pp_colour_addb" ] = 0
                tab[ "$pp_colour_brightness" ] = 0
                tab[ "$pp_colour_contrast" ] = 1
                tab[ "$pp_colour_colour" ] = 0.9
                DrawColorModify(tab)
            end)
        end

        -- Random wretch/vomit timer
        local id = "ixNausea_" .. ply:SteamID64()
        timer.Create(id, math.random(10, 20), 0, function()
            if not IsValid(ply) or not ply:GetNetVar("nausea") then
                timer.Remove(id)
                return
            end

            if math.random(3) == 1 then
                ply:EmitSound("npc/barnacle/barnacle_digesting1.wav", 70, 100)
                ix.chat.Send(ply, "notice", ply:Name() .. " looks like they might vomit.")
                -- Vomit decal
                local tr = util.TraceLine({
                    start = ply:EyePos(),
                    endpos = ply:EyePos() + ply:GetForward() * 50,
                    filter = ply
                })
                if tr.Hit then
                    util.Decal("BeerSplash", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
                end
            end
        end)
    end,
    exit = function(ply)
        ply:Notify("Your nausea subsides.")
        if CLIENT and ply == LocalPlayer() then
            hook.Remove("RenderScreenspaceEffects", "ixNauseaTint")
        end
        timer.Remove("ixNausea_" .. ply:SteamID64())
    end
}
