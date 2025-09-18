ITEM.name = "9mm Ammo"
ITEM.description = "A box of 9mm rounds."
ITEM.model = "models/items/boxsrounds.mdl"
ITEM.category = "Ammunition"
ITEM.width = 1
ITEM.height = 1
ITEM.maxQuantity = 30 -- per item; can be any number you prefer
ITEM.quantity = 30

if CLIENT then
    function ITEM:PaintOver(item, w, h)
        local qty = item:GetData("quantity", 1)
        draw.SimpleText(
            tostring(qty),
            "DermaDefault",
            w - 5, h - 5,
            color_white,
            TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM,
            1, color_black
        )
    end
end

-- Combine two ammo stacks
ITEM.functions.combine = {
  OnRun = function(item, data)
    local other = ix.item.instances[data[1]]
    if not other or other.uniqueID ~= item.uniqueID or other == item then return false end

    local a, b = item:GetData("quantity",1), other:GetData("quantity",1)
    local total = a + b
    local cap   = item.maxQuantity

    if total <= cap then
      item:SetData("quantity", total, ix.inventory.Get(item.invID):GetReceivers())
      other:Remove()
    else
      item:SetData("quantity", cap, ix.inventory.Get(item.invID):GetReceivers())
      other:SetData("quantity", total - cap, ix.inventory.Get(other.invID):GetReceivers())
    end

    return false
  end,
  OnCanRun = function(item, data)
    local other = ix.item.instances[data and data[1] or 0]
    return other and other.uniqueID == item.uniqueID and other ~= item
  end
}
