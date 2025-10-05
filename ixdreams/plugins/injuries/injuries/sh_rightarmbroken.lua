PLUGIN.injuries.rightarmbroken = {
    condition = function(ply, dmgInfo, hitgroup)
        return hitgroup == HITGROUP_RIGHTARM and math.random(3) == 1
    end,
    enter = function(ply)
        ply:Notify("Your right arm is broken!")
    end,
    exit = function(ply)
        ply:Notify("Your right arm heals.")
    end
}
