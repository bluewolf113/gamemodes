ITEM.name = "Suitcase"
ITEM.description = "A small suitcase."
ITEM.model = Model("models/weapons/w_suitcase_passenger.mdl")
ITEM.openSound = "items/ammocrate_close.wav"

ITEM.weaponClass = "weapon_hl2_suitcase"

-- Give the suitcase weapon
ITEM.functions.Equip = {
    name = "Hold",
    tip = "Equip the suitcase weapon.",
    icon = "icon16/brick.png",

    OnCanRun = function(item)
        local ply = item.player
        return IsValid(ply) and not ply:HasWeapon(item.weaponClass)
    end,

    OnRun = function(item)
        local ply = item.player

        if IsValid(ply) and not ply:HasWeapon(item.weaponClass) then
            ply:Give(item.weaponClass)
        end

        return false -- keep the item in inventory
    end
}

ITEM.functions.Unequip = {
    name = "Unequip",
    tip = "Remove the suitcase weapon.",
    icon = "icon16/delete.png",

    OnCanRun = function(item)
        local ply = item.player
        return IsValid(ply) and ply:HasWeapon(item.weaponClass)
    end,

    OnRun = function(item)
        local ply = item.player

        if IsValid(ply) and ply:HasWeapon(item.weaponClass) then
            ply:StripWeapon(item.weaponClass)
        end

        return false -- keep the item in inventory
    end
}