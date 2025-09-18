PLUGIN.name        = "Magazines"
PLUGIN.author      = "Nicholas Gioletti & Copilot"
PLUGIN.description = "Physical magazine reload and ejection system."

if SERVER then
    function PLUGIN:KeyPress(client, key)
        if key ~= IN_RELOAD then return end
        if not client:Alive() then return end

        local char = client:GetCharacter()
        if not char then return end

        local swep = client:GetActiveWeapon()
        if not IsValid(swep) then return end

        local inv = char:GetInventory()
        if not inv then return end

        -- Find matching weapon item
        local weaponItem
        for _, item in pairs(inv:GetItems()) do
            if item.class == swep:GetClass() then
                weaponItem = item
                break
            end
        end
        if not weaponItem then return end

        local compatibleMag = weaponItem.compatibleMag
        local maxAmmo       = weaponItem.maxAmmo or 0
        local ammoType      = weaponItem.ammo or "pistol"
        local useSound      = weaponItem.useSound or "items/ammo_pickup.wav"

        if not compatibleMag or maxAmmo <= 0 then return end
        client:RemoveAmmo(client:GetAmmoCount(ammoType), ammoType)
        -- Eject current magazine if present
        local oldMag = weaponItem:GetData("loadedMag")
        if oldMag then
            local oldMagID = oldMag.uniqueID or compatibleMag
            local rounds = oldMag.rounds or 0
            if rounds > 0 then
                client:RemoveAmmo(rounds, ammoType)
            end
            if not inv:Add(oldMagID, 1, { rounds = rounds }) then
                ix.item.Spawn(oldMagID, client, nil, angle_zero, { rounds = rounds })
            end
        end

        -- Find fullest compatible magazine
        local bestMag, bestRounds = nil, 0
        for _, item in pairs(inv:GetItems()) do
            if item.uniqueID == compatibleMag then
                local rounds = item:GetData("rounds", 0)
                if rounds > bestRounds then
                    bestRounds = rounds
                    bestMag = item
                end
            end
        end

        if not bestMag or bestRounds <= 0 then
            client:Notify("No loaded magazines available.")
            return
        end

        local loadAmount = math.min(bestRounds, maxAmmo)

        -- Strip leftover ammo before loading
        

        client:GiveAmmo(loadAmount, ammoType)
        client:EmitSound(useSound, 110)

        weaponItem:SetData("loadedMag", {
            rounds = loadAmount,
            uniqueID = bestMag.uniqueID
        }, inv:GetReceivers())

        bestMag:Remove()

        client:Notify("Reloaded pistol with " .. loadAmount .. " rounds.")
    end

    -- Sync ammo on fire
    hook.Add("EntityFireBullets", "ix.MagazineAmmoSync", function(ent, data)
        if not IsValid(ent) or not ent:IsPlayer() then return end

        local char = ent:GetCharacter()
        if not char then return end

        local inv = char:GetInventory()
        if not inv then return end

        local swep = ent:GetActiveWeapon()
        if not IsValid(swep) then return end

        local weaponItem
        for _, item in pairs(inv:GetItems()) do
            if item.class == swep:GetClass() then
                weaponItem = item
                break
            end
        end
        if not weaponItem then return end

        local mag = weaponItem:GetData("loadedMag")
        if not mag or not mag.rounds or mag.rounds <= 0 then return end

        mag.rounds = mag.rounds - 1
        weaponItem:SetData("loadedMag", mag, inv:GetReceivers())

        if mag.rounds <= 0 then
            ent:Notify("Your magazine is empty.")
        end
    end)
end