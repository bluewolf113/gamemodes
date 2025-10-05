PLUGIN.injuries.bleeding = {
    condition = function(ply, dmgInfo, hitgroup, dt)
        return bit.band(dt, bit.bor(DMG_BULLET, DMG_CLUB, DMG_SLASH)) ~= 0
    end,
    enter = function(ply)
        ply:Notify("You are bleeding!")
        local id = "ixBleeding_" .. ply:SteamID64()

        timer.Create(id, 5, 0, function()
            if not IsValid(ply) or not ply:GetNetVar("bleeding") then
                timer.Remove(id)
                return
            end

            -- Place blood decal under player
            local startPos = ply:GetPos() + Vector(20, 0, 10)
            local endPos = startPos - Vector(0, 0, 500)

            local tr = util.TraceHull({
                start = startPos,
                endpos = endPos,
                mins = Vector(-4, -4, 0),
                maxs = Vector(4, 4, 1),
                filter = ply,
                mask = MASK_SOLID
            })

            if tr.Hit then
                util.Decal("Blood", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal, tr.Entity)
            end

            -- Apply damage
            local hp = ply:Health()
            if hp > 5 then
                ply:SetHealth(hp - 2)
                if SERVER then
                    net.Start("ixInjuryFlash")
                    net.Send(ply)
                end
            else
                ply:Kill()
                timer.Remove(id)
            end
        end)
    end,
    exit = function(ply)
        ply:Notify("Your bleeding has stopped.")
        timer.Remove("ixBleeding_" .. ply:SteamID64())
    end
}
