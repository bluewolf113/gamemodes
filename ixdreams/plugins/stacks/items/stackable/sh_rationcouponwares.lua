ITEM.name = "Wares Ration Coupon"
ITEM.description = "Test."
ITEM.category = "Currency"
ITEM.model = "models/illusion/eftcontainers/alyonka.mdl"
ITEM.maxStacks = 25

function ITEM:GetMaterial()
    return "models/XQM/WoodTexture_1"
end

if CLIENT then
    function ITEM:PaintOver(item, w, h)
        -- Bottom-right: stack count
        draw.SimpleText(
            item:GetData("stacks", 1),
            "DermaDefault",
            w - 5, h - 5,
            color_white,
            TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM,
            1, color_black
        )
    end
end

function ITEM:GetName()
    local count = self:GetData("stacks", 1)
    local baseName = self.name or "Item"

    -- If more than one, pluralize by adding "s"
    if count > 1 then
        local pluralName = baseName
        if not pluralName:lower():EndsWith("s") then
            pluralName = pluralName .. "s"
        end

        local prefix = self.stackName or ""
        if prefix ~= "" then
            return string.format("%s of %d %s", prefix, count, pluralName)
        else
            return string.format("%d %s", count, pluralName)
        end
    end

    return baseName
end
