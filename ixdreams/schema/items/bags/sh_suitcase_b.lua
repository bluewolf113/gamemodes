ITEM.name = "Suitcase"
ITEM.description = "A small suitcase."
ITEM.model = Model("models/props_c17/SuitCase001a.mdl")

ITEM.weaponClass = "weapon_hl2_suitcase_b"

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