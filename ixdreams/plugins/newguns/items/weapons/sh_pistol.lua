ITEM.name = ".9mm Pistol test"
ITEM.description = "A sidearm utilising 9mm ammunition."
ITEM.uniqueID = "weapon_pistol"
ITEM.model = "models/weapons/w_pistol.mdl"
ITEM.class = "weapon_pistol"
ITEM.weaponCategory = "sidearm"
ITEM.width = 2
ITEM.height = 1
ITEM.maxAmmo = 8
ITEM.compatibleMag = "9mm_mag"
ITEM.ammo = "pistol"
ITEM.useSound = "items/ammo_pickup.wav"

function ITEM:OnRegistered()
    if ix.ammo then
        ix.ammo.Register(self.ammo)
    end
end

if CLIENT then
    function ITEM:PaintOver(item, w, h)
        local mag = item:GetData("loadedMag", {})
        local rounds = mag.rounds or 0
        draw.SimpleText(
            rounds .. "/" .. item.maxAmmo,
            "DermaDefault",
            w - 5, h - 5,
            color_white,
            TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM,
            1, color_black
        )
    end
end

ITEM.functions.combine = {
    name = "Load Magazine",
    icon = "icon16/add.png",
    OnRun = function(item, data)
        local mag = ix.item.instances[data[1]]
        if not mag or mag.uniqueID ~= item.compatibleMag then return false end

        local rounds = mag:GetData("rounds", 0)
        if rounds <= 0 then
            item.player:Notify("That magazine is empty.")
            return false
        end

        -- Eject old mag if present
        local oldMag = item:GetData("loadedMag")
        if oldMag then
            local oldMagID = oldMag.uniqueID or item.compatibleMag
            local oldRounds = oldMag.rounds or 0
            if oldRounds > 0 then
                item.player:RemoveAmmo(oldRounds, item.ammo)
            end
            local inv = item.player:GetCharacter():GetInventory()
            if not inv:Add(oldMagID, 1, { rounds = oldRounds }) then
                ix.item.Spawn(oldMagID, item.player, nil, angle_zero, { rounds = oldRounds })
            end
        end

        local loadAmount = math.min(rounds, item.maxAmmo)

        item.player:RemoveAmmo(item.player:GetAmmoCount(item.ammo), item.ammo)
        item.player:GiveAmmo(loadAmount, item.ammo)
        item.player:EmitSound(item.useSound, 110)

        item:SetData("loadedMag", {
            rounds = loadAmount,
            uniqueID = mag.uniqueID
        }, ix.inventory.Get(item.invID):GetReceivers())

        mag:Remove()

        item.player:Notify("Loaded the pistol with " .. loadAmount .. " rounds.")
        return false
    end,
    OnCanRun = function(item, data)
        local mag = ix.item.instances[data[1]]
        return mag and mag.uniqueID == item.compatibleMag
    end
}

ITEM.functions.ejectmag = {
    name = "Eject Magazine",
    icon = "icon16/arrow_out.png",
    OnRun = function(item)
        local client = item.player
        local magData = item:GetData("loadedMag")

        if not magData then
            client:Notify("No magazine to eject.")
            return false
        end

        local magID = magData.uniqueID or item.compatibleMag
        local rounds = magData.rounds or 0

        if rounds > 0 then
            client:RemoveAmmo(rounds, item.ammo)
        end

        local inv = client:GetCharacter():GetInventory()
        if not inv:Add(magID, 1, { rounds = rounds }) then
            ix.item.Spawn(magID, client, nil, angle_zero, { rounds = rounds })
        end

        item:SetData("loadedMag", nil, ix.inventory.Get(item.invID):GetReceivers())
        item:SetData("ammo", 0, ix.inventory.Get(item.invID):GetReceivers())

        client:Notify("Ejected magazine with " .. rounds .. " rounds.")
        return false
    end,
    OnCanRun = function(item)
        return item:GetData("loadedMag") ~= nil
    end
}