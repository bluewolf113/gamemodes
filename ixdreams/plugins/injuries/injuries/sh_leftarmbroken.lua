PLUGIN.injuries.leftarmbroken = {
    condition = function(ply, dmgInfo, hitgroup)
        return hitgroup == HITGROUP_LEFTARM and math.random(3) == 1
    end,
    enter = function(ply)
        ply:Notify("Your left arm is broken!")
    end,
    exit = function(ply)
        ply:Notify("Your left arm heals.")
    end
}
