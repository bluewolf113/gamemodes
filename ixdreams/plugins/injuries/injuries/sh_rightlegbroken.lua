PLUGIN.injuries.rightlegbroken = {
    condition = function(ply, dmgInfo, hitgroup)
        return bit.band(dmgInfo:GetDamageType(), DMG_FALL) ~= 0 and math.random(2) == 1
    end,
    enter = function(ply)
        ply:Notify("Your right leg is broken!")
        ply:SetWalkSpeed(ply:GetWalkSpeed() * 0.5)
        ply:SetRunSpeed(ply:GetRunSpeed() * 0.5)
        if SERVER then
            net.Start("ixRightLegBrokenFlash")
            net.Send(ply)
        end
    end,
    exit = function(ply)
        ply:Notify("Your right leg heals.")
        ply:SetWalkSpeed(ix.config.Get("walkSpeed", 130))
        ply:SetRunSpeed(ix.config.Get("runSpeed", 235))
    end
}