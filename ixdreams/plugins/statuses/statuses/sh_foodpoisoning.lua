PLUGIN.injuries.foodpoisoning = {
    condition = function(ply, dmgInfo, hitgroup)
        -- Example: triggered by poison damage with higher chance
        return bit.band(dmgInfo:GetDamageType(), DMG_POISON) ~= 0 and math.random(2) == 1
    end,
    enter = function(ply)
        ply:Notify("You feel sick... food poisoning sets in.")

        -- Progression timer
        local id = "ixFoodPoisoning_" .. ply:SteamID64()
        local ticks = 0
        timer.Create(id, 15, 0, function()
            if not IsValid(ply) or not ply:GetNetVar("foodpoisoning") then
                timer.Remove(id)
                return
            end

            ticks = ticks + 1
            ply:Notify("Your stomach churns...")

            -- After a few ticks, escalate into fever
            if ticks >= 4 and not ply:GetNetVar("fever") then
                local plugin = ix.plugin.list["injuries"]
                if plugin then
                    plugin:ApplyEffect(ply, "fever")
                end
            end
        end)
    end,
    exit = function(ply)
        ply:Notify("Your food poisoning passes.")
        timer.Remove("ixFoodPoisoning_" .. ply:SteamID64())
    end
}