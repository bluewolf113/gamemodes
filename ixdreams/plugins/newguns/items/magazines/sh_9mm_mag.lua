ITEM.name             = "9mm Magazine"
ITEM.description      = "A detachable magazine for 9mm firearms."
ITEM.uniqueID         = "9mm_mag"
ITEM.model            = "models/items/boxmrounds.mdl"
ITEM.category         = "Magazines"
ITEM.width            = 1
ITEM.height           = 1
ITEM.maxRounds        = 8
ITEM.ammoType         = "9mm_ammo"
ITEM.compatibleWeapon = "weapon_pistol"

if CLIENT then
  function ITEM:PaintOver(item, w, h)
    local rounds = item:GetData("rounds", 0)
    local max    = self.maxRounds or 0
    draw.SimpleText(
      rounds .. "/" .. max,
      "DermaDefault",
      w - 5, h - 5,
      color_white,
      TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM,
      1, color_black
    )
  end
end

-- Load from ammo box
ITEM.functions.combine = {
  OnRun = function(magItem, data)
    local other = ix.item.instances[data[1]]
    if not other or other.uniqueID ~= magItem.ammoType then
      return false
    end

    local cur   = magItem:GetData("rounds", 0)
    if cur >= magItem.maxRounds then
      magItem.player:Notify("Magazine is already full.")
      return false
    end

    local ammoQty = other:GetData("quantity", 1)
    local space   = magItem.maxRounds - cur
    local toLoad  = math.min(space, ammoQty)

    magItem:SetData("rounds", cur + toLoad, ix.inventory.Get(magItem.invID):GetReceivers())

    if ammoQty > toLoad then
      other:SetData("quantity", ammoQty - toLoad, ix.inventory.Get(other.invID):GetReceivers())
    else
      other:Remove()
    end

    magItem.player:Notify("Loaded " .. toLoad .. " rounds into the magazine.")
    return false
  end,
  OnCanRun = function(magItem, data)
    local other = ix.item.instances[data[1]]
    return other and other.uniqueID == magItem.ammoType
       and magItem:GetData("rounds", 0) < magItem.maxRounds
  end
}

-- Unload one round
ITEM.functions.unload1 = {
  name     = "Unload 1",
  icon     = "icon16/delete.png",
  OnRun    = function(item)
    local client = item.player
    local cur    = item:GetData("rounds", 0)
    if cur <= 0 then
      client:Notify("Magazine is empty.")
      return false
    end

    item:SetData("rounds", cur - 1, ix.inventory.Get(item.invID):GetReceivers())
    if not client:GetCharacter():GetInventory():Add(item.ammoType, 1, { quantity = 1 }) then
      ix.item.Spawn(item.ammoType, client, nil, angle_zero, { quantity = 1 })
    end
    return false
  end,
  OnCanRun = function(item)
    return item:GetData("rounds", 0) > 0
  end
}

-- Unload all rounds
ITEM.functions.unloadall = {
  name     = "Empty All",
  icon     = "icon16/delete_all.png",
  OnRun    = function(item)
    local client = item.player
    local cur    = item:GetData("rounds", 0)
    if cur <= 0 then
      client:Notify("Magazine is empty.")
      return false
    end

    item:SetData("rounds", 0, ix.inventory.Get(item.invID):GetReceivers())
    if not client:GetCharacter():GetInventory():Add(item.ammoType, 1, { quantity = cur }) then
      ix.item.Spawn(item.ammoType, client, nil, angle_zero, { quantity = cur })
    end
    return false
  end,
  OnCanRun = function(item)
    return item:GetData("rounds", 0) > 0
  end
}