ITEM.name = "Base Magazine Weapon"
ITEM.description = "A weapon that uses detachable magazines."
ITEM.category = "Weapons"
ITEM.model = "models/weapons/w_pistol.mdl"
ITEM.class = "weapon_pistol"
ITEM.width = 2
ITEM.height = 2
ITEM.isWeapon = true
ITEM.isGrenade = false
ITEM.weaponCategory = "sidearm"
ITEM.useSound = "items/ammo_pickup.wav"

-- Which magazines this weapon can accept
ITEM.acceptableMags = { "pistolmag" }

ITEM.magazine = {
    uniqueID = nil,
    ammo = 0
}

function ITEM:GetMagazineStatus()
    local magData = self:GetData("magazine", {uniqueID = nil, ammo = 0})
    if magData.uniqueID then
        return "Loaded: " .. magData.ammo .. " rounds"
    else
        return "No magazine inserted"
    end
end

if CLIENT then
    function ITEM:PopulateTooltip(tooltip)
        local row = tooltip:AddRow("magazineStatus")
        row:SetText(self:GetMagazineStatus())
        row:SetBackgroundColor(Color(200, 200, 255))
        row:SizeToContents()
    end
end

-- Insert magazine
ITEM.functions.combine = {
    name = "Insert Magazine",
    tip = "Load this weapon with a magazine.",
    icon = "icon16/add.png",

    OnRun = function(item, data)
        local client = item.player
        local targetItem = ix.item.instances[data[1]]
        if not IsValid(client) or not targetItem then return false end

        local magData = item:GetData("magazine", {uniqueID = nil, ammo = 0})
        if magData.uniqueID then
            client:Notify("This weapon already has a magazine inserted.")
            return false
        end

        if targetItem.magAmmoCount and targetItem.maxAmmo then
            item:SetData("magazine", {
                uniqueID = targetItem.uniqueID,
                ammo = targetItem.magAmmoCount
            })
            targetItem:Remove()
        else
            client:Notify("This item is not a valid magazine.")
        end

        return false
    end,

    OnCanRun = function(item, data)
        local targetItem = ix.item.instances[data and data[1] or 0]
        return targetItem and targetItem.magAmmoCount and targetItem.maxAmmo
    end
}

-- Eject magazine
ITEM.functions.EjectMagazine = {
    name = "Eject Magazine",
    tip = "Remove the magazine from this weapon.",
    icon = "icon16/delete.png",

    OnRun = function(item)
        local client = item.player
        if not IsValid(client) then return false end

        local magData = item:GetData("magazine", {uniqueID = nil, ammo = 0})
        if not magData.uniqueID then
            client:Notify("No magazine is inserted.")
            return false
        end

        local weapon = client:GetActiveWeapon()
        if IsValid(weapon) then
            magData.ammo = weapon:Clip1()
            weapon:SetClip1(0)
        end

        local inv = client:GetCharacter():GetInventory()
        if inv then
            inv:Add(magData.uniqueID, 1, function(newItem)
                newItem.magAmmoCount = magData.ammo
            end)
        end

        item:SetData("magazine", {uniqueID = nil, ammo = 0})
        return false
    end,

    OnCanRun = function(item)
        local magData = item:GetData("magazine", {uniqueID = nil})
        return IsValid(item.player) and magData.uniqueID
    end
}