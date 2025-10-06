ITEM.name = "Test"
ITEM.model = Model("models/props_junk/watermelon01.mdl")
ITEM.width = 3
ITEM.height = 3
ITEM.description = "Get descs"
ITEM.category = "Food"

ITEM.functions.Spray = {
    name = "Spray",
    tip = "Spray a decal at your feet.",
    icon = "icon16/asterisk_orange.png",

    OnRun = function(item)
        local client = item.player
        if not IsValid(client) then return false end

        local startPos = client:GetPos() + Vector(20, 0, 10)
        local endPos = startPos - Vector(0, 0, 500) -- Trace far downward

        local tr = util.TraceHull({
            start = startPos,
            endpos = endPos,
            mins = Vector(-4, -4, 0),
            maxs = Vector(4, 4, 1),
            filter = client,
            mask = MASK_SOLID
        })

        if tr.Hit then
            local decalName = "Cross"
            local hitPos = tr.HitPos
            local normal = tr.HitNormal

            util.Decal(decalName, hitPos + normal, hitPos - normal, tr.Entity)
            client:EmitSound("npc/roller/mine/rmine_tossed1.wav", 70, 100)
        else
            ix.util.Notify("No suitable surface found beneath you to spray on.", client)
        end

        return false
    end,

    OnCanRun = function(item)
        return IsValid(item.player) and not IsValid(item.entity)
    end
}

ITEM.functions.combine = {
    OnRun = function(item, data)
        local targetItem = ix.item.instances[data[1]] -- this is the knife
        local player = item.player

        -- Remove this item (e.g., the watermelon)
        item:Remove()

        -- Give paper to the player
        local inv = player:GetCharacter():GetInventory()
            inv:Add("watermelonhalf")
            inv:Add("watermelonhalf")
            
        client:EmitSound("physics/flesh/flesh_squishy_impact_hard4.wav", 60, 100)

        return false -- the knife is kept
    end,

    OnCanRun = function(item, data)
        local targetItem = ix.item.instances[data[1]]

        -- Only allow combine if the target item is a knife
        return targetItem and targetItem.uniqueID == "bowieknife"
    end
}
