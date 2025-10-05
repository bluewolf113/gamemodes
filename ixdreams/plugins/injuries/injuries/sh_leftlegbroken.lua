PLUGIN.injuries.rightlegbroken = {
    condition = function(ply, dmgInfo, hitgroup)
        if dmgInfo:IsFallDamage() and math.random(2) == 1 then return true end
        return hitgroup == HITGROUP_RIGHTLEG and math.random(3) == 1
    end,
    enter = function(ply)
        ply:Notify("Your right leg is broken!")
        ply:SetWalkSpeed(ply:GetWalkSpeed() * 0.5)
        ply:SetRunSpeed(ply:GetRunSpeed() * 0.5)
    end,
    exit = function(ply)
        ply:Notify("Your right leg heals.")
        ply:SetWalkSpeed(ix.config.Get("walkSpeed", 130))
        ply:SetRunSpeed(ix.config.Get("runSpeed", 235))
    end
}
