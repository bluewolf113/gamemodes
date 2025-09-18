local PLUGIN = PLUGIN

PLUGIN.equippedMags = PLUGIN.equippedMags or {}

-- Returns the equipped magazine table for a client (keyed by SteamID)
function PLUGIN:GetEquippedMags(client)
    local id = client:SteamID()
    self.equippedMags[id] = self.equippedMags[id] or {}
    return self.equippedMags[id]
end

-- Equips a magazine item for a client (max 5 equipped)
function PLUGIN:EquipMagazine(client, item)
    local mags = self:GetEquippedMags(client)
    if #mags >= 5 then
        return false, "You cannot equip more than 5 magazines."
    end

    table.insert(mags, item)
    return true
end

-- Unequips a magazine item for a client
function PLUGIN:UnequipMagazine(client, item)
    local mags = self:GetEquippedMags(client)
    for i, v in ipairs(mags) do
        if v == item then
            table.remove(mags, i)
            return true
        end
    end
    return false, "Magazine not equipped."
end

-- Reload function: chooses the spare magazine with the highest ammo count.
function PLUGIN:ReloadMagazine(client)
    local mags = self:GetEquippedMags(client)
    if #mags < 2 then
        return false, "Not enough magazines to reload."
    end

    local currentMag = mags[1]
    local bestMag = nil
    local bestAmmo = -1

    for i = 2, #mags do
        local mag = mags[i]
        local ammoCount = mag:GetData("ammoCount", mag.magSize)
        if ammoCount > bestAmmo then
            bestAmmo = ammoCount
            bestMag = mag
        end
    end

    if not bestMag then
        return false, "No spare magazine available."
    end

    -- Swap bestMag with the current magazine
    for i, mag in ipairs(mags) do
        if mag == bestMag then
            table.remove(mags, i)
            break
        end
    end
    table.insert(mags, 1, bestMag)

    -- Simulate that a fresh magazine is loaded:
    if bestMag:GetData("ammoCount", bestMag.magSize) < bestMag.magSize then
        bestMag:SetData("ammoCount", bestMag.magSize)
    end

    net.Start("MagazineReloaded")
        net.WriteString("Magazine reloaded. New magazine loaded with " .. bestMag:GetData("ammoCount", bestMag.magSize) .. " rounds.")
    net.Send(client)

    return true
end

-- Hook into the default weapon reload action
hook.Add("KeyPress", "ReloadUsingEquippedMags", function(client, key)
    if key == IN_RELOAD then
        local weapon = client:GetActiveWeapon()
        if IsValid(weapon) then
            local success, err = PLUGIN:ReloadMagazine(client)
            if not success then
                client:ChatPrint(err)
            end
        end
    end
end)
