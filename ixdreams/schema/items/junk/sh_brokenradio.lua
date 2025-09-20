-- bread.lua
ITEM.name = "Broken Radio"
ITEM.category = "Tools"
ITEM.model = "models/props_lab/citizenradio.mdl"
ITEM.width = 2
ITEM.height = 3

ITEM.combineRemove = true -- consume the bread
ITEM.combineSound = "foley/alyx_hug_eli.wav"
ITEM.combineThings = {"screwdriver"} -- either works

ITEM.functions.combine = {
    OnRun = function(item, data)
        local client = item.player
        local target = ix.item.instances[data and data[1]]
        if not (IsValid(client) and target) then return false end

        local char = client:GetCharacter()
        local inv = char and char:GetInventory()
        if not inv then return false end

        for _, id in ipairs(item.combineThings) do
            if target.uniqueID == id then
                local movementKeys = {
                    [KEY_W] = true, [KEY_A] = true, [KEY_S] = true, [KEY_D] = true,
                    [KEY_SPACE] = true, [KEY_LSHIFT] = true
                }

                local cancelHook = "ixCombineCancel_" .. client:SteamID()
                local canceled = false

                hook.Add("PlayerButtonDown", cancelHook, function(ply, button)
                    if ply == client and movementKeys[button] then
                        canceled = true
                        client:SetAction()
                        client:Notify("You moved and canceled the combine.")
                        hook.Remove("PlayerButtonDown", cancelHook)
                    end
                end)

                client:SetAction("Combining items...", 2, function()
                    hook.Remove("PlayerButtonDown", cancelHook)
                    if canceled then return end

                    if item.combineSound then
                        client:EmitSound(item.combineSound)
                    end

                    -- just add items, no space checks
                    inv:Add("electronicscrap")
                    inv:Add("electronicscrap")
                    inv:Add("scrapmetal")
                    inv:Add("screws")

                    if item.combineRemove then
                        item:Remove()
                    end

                    client:Notify("You salvaged the radio for parts.")
                end)

                return false
            end
        end

        client:Notify("Those items cannot be combined.")
        return false
    end,

    OnCanRun = function(item, data)
        local target = ix.item.instances[data and data[1]]
        if not (target and item.combineThings) then return false end

        for _, id in ipairs(item.combineThings) do
            if target.uniqueID == id then return true end
        end

        return false
    end
}

