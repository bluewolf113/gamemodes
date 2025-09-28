ITEM.name = "Car Battery"
ITEM.description = "Detonates instantly. Kills nearby players."
ITEM.model = "models/props_c17/oildrum001_explosive.mdl"
ITEM.category = "Weapons"

ITEM.functions.Use = {
    OnRun = function(item)
        local ply = item.player
        local pos = ply:GetPos()

        local radius = 500

        ix.chat.Send(ply, "localevent", "Something triggers in the box. It detonates.", nil, nil, {range = radius})

        ply:EmitSound("phx/hmetal1.wav", 50)

        timer.Simple(3, function()
            if not IsValid(ply) then return end

            local explosion = ents.Create("env_explosion")
            explosion:SetPos(pos)
            explosion:SetOwner(ply)
            explosion:Spawn()
            explosion:SetKeyValue("iMagnitude", "250")
            explosion:Fire("Explode", 0, 0)
        end)

        item:Remove()
        return false
    end,
    OnCanRun = function(item)
        return IsValid(item.player) and not item.entity
    end
}