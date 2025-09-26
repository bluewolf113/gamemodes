PLUGIN.name = "mag test"
PLUGIN.description = "Adds support for tracking liquids inside of containers, and sources to fill them."
PLUGIN.author = "blue"

if SERVER then
    hook.Add("EntityFireBullets", "DrainMagazineOnFire", function(ply, data)
        if not IsValid(ply) or not ply:IsPlayer() then return end

        local weapon = ply:GetActiveWeapon()
        if not IsValid(weapon) then return end

        -- Helix base sets this when equipping
        local item = weapon.ixItem
        if not item or not item.GetData then return end

        -- Get current mag data
        local magData = item:GetData("magazine", { uniqueID = nil, ammo = 0 })
        if not magData.uniqueID then
            -- no mag inserted
            ply:EmitSound("Weapon_Pistol.Empty")
            weapon:SetClip1(0)
            return
        end

        if magData.ammo <= 0 then
            -- mag is empty
            ply:EmitSound("Weapon_Pistol.Empty")
            weapon:SetClip1(0)
            return
        end

        -- Drain one round
        magData.ammo = magData.ammo - 1

        -- Sync SWEP clip to mag ammo
        weapon:SetClip1(magData.ammo)

        -- Persist back into the item
        item:SetData("magazine", magData)
    end)
end


if SERVER then
    function PLUGIN:KeyPress(client, key)
        if key ~= IN_RELOAD then return end
        if not client:Alive() then return end

        -- only reload if weapon is raised
        if not (ix.event and ix.event.IsWeaponRaised(client)) then return end

        local char = client:GetCharacter()
        if not char then return end

        local swep = client:GetActiveWeapon()
        if not IsValid(swep) then return end

        local inv = char:GetInventory()
        if not inv then return end

        -- find the weapon item in inventory
        local weaponItem
        for _, item in pairs(inv:GetItems()) do
            if item.class == swep:GetClass() then
                weaponItem = item
                break
            end
        end
        if not weaponItem then return end

        local compatibleMag = weaponItem.compatibleMag
        if not compatibleMag then return end

        -- eject current mag
        local magData = weaponItem:GetData("magazine", { uniqueID = nil, ammo = 0 })
        if magData.uniqueID then
            local rounds = swep:Clip1()
            swep:SetClip1(0)

            if not inv:Add(magData.uniqueID, 1, { rounds = rounds }) then
                ix.item.Spawn(magData.uniqueID, client, nil, angle_zero, { rounds = rounds })
            end

            weaponItem:SetData("magazine", { uniqueID = nil, ammo = 0 })
        end

        -- find fullest compatible mag
        local bestMag, bestRounds = nil, 0
        for _, mag in pairs(inv:GetItems()) do
            if mag.uniqueID == compatibleMag then
                local rounds = mag:GetData("rounds", 0)
                if rounds > bestRounds then
                    bestRounds = rounds
                    bestMag = mag
                end
            end
        end

        if not bestMag or bestRounds <= 0 then
            client:Notify("No loaded magazines available.")
            return
        end

        -- insert best mag
        weaponItem:SetData("magazine", {
            uniqueID = bestMag.uniqueID,
            ammo = bestRounds
        })
        swep:SetClip1(bestRounds)
        if swep.Reload then
            swep:Reload()
        elseif swep.DefaultReload then
            swep:DefaultReload(ACT_VM_RELOAD)
        end

        client:Notify("Reloaded with magazine containing " .. bestRounds .. " rounds.")
        bestMag:Remove()
    end
end