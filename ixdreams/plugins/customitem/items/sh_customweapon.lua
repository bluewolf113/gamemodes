ITEM.name = "Custom Weapon"
ITEM.description = "A unique weapon."
ITEM.model = "models/weapons/w_pistol.mdl"
ITEM.category = "Weapons"

-- Pulls from saved item data
function ITEM:GetName()
    return self:GetData("name", "Custom Weapon")
end

function ITEM:GetDescription()
    return self:GetData("description", "A weapon of unknown origin.")
end

function ITEM:GetModel()
    return self:GetData("model", self.model)
end

-- Weapon base specifics
function ITEM:GetClass()
    return self:GetData("wepClass", "weapon_pistol")
end

function ITEM:GetAmmo()
    return self:GetData("ammo", 0)
end

function ITEM:GetAmmoType()
    return self:GetData("ammoType", "Pistol")
end

function ITEM:GetClip()
    return self:GetData("clip", 0)
end

-- When equipped
function ITEM:OnEquipWeapon(client, weapon)
    -- Optional: set clip
    local clip = self:GetClip()
    if clip and clip > 0 then
        weapon:SetClip1(clip)
    end
end

-- When unequipped
function ITEM:OnUnequipWeapon(client, weapon)
    -- Save remaining ammo/clip if desired
    self:SetData("clip", weapon:Clip1())
end
