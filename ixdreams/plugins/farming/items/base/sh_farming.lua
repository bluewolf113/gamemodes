ITEM.name = "Base Farming"
ITEM.description = "Небольшая упаковка с семенами."
ITEM.model = Model("models/props_lab/box01a.mdl")
ITEM.category = "categoryFarming"
ITEM.width = 1
ITEM.height = 1
ITEM.rarity = 1
ITEM.surfaces = {
	[MAT_DIRT] = true,
	[MAT_GRASS] = true,
	[MAT_FOLIAGE] = true
}

ITEM.functions.Plant = {
    name = "Plant",
    icon = "icon16/accept.png",

    OnRun = function(item)
        local client = item.player
        local tr = client:GetEyeTraceNoCursor()

        if (tr.Hit and item.surfaces[tr.MatType]) then
            if client:EyePos():Distance(tr.HitPos) > 90 then
                client:Notify("You’re too far from the ground.")
                return false
            end

            local plant = ents.Create("ix_plant")
            plant:SetClass(item.seedclass)
            plant:SetPlantName(item.plantName)
            plant.product   = item.product
            plant.growmodels = item.growmodels or {}

            -- spawn just above ground
            tr.HitPos.z = tr.HitPos.z + 2
            plant:SetPos(tr.HitPos)
            plant:Spawn()

            return true
        end

        return false
    end,

    OnCanRun = function(item)
        return true
    end
}