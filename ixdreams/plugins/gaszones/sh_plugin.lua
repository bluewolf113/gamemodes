local PLUGIN = PLUGIN

PLUGIN.name = "Gas Zone"
PLUGIN.author = "Nicholas"
PLUGIN.description = "Toxic gas zones that damage players over time."

if ix.area then
    function PLUGIN:SetupAreaProperties()
        if SERVER then
            if timer.Exists("ixGasAreaThink") then
                timer.Remove("ixGasAreaThink")
            end

            timer.Create("ixGasAreaThink", ix.config.Get("areaTickTime", 1), 0, function()
                self:GasAreaThink()
            end)
        end

        ix.area.AddType("gaszone", "Gas Zone")
    end
end

function PLUGIN:GasAreaThink()
    for _, client in player.Iterator() do
        if not client:Alive() then continue end

        local char = client:GetCharacter()
        if not char then continue end

        if not client:IsInArea() then continue end

        local areaID = client:GetArea()
        local areaData = ix.area.stored[areaID]

        if not areaData or areaData.type != "gaszone" then continue end

        local inv = char:GetInventory()
        if not inv then continue end

        local protected = false

        for _, item in pairs(inv:GetItems()) do
            if item.isGasmask and item:GetData("equip") then
                protected = true
                break
            end
        end

        if protected then
            client:Notify("You're okay.")
        else
            if char.AddStatusEffect then
                char:AddStatusEffect("poison_light", 1)
            end

            client:Notify("It hurts.")
        end
    end
end
