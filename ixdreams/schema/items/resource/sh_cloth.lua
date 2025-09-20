-- bread.lua
ITEM.name = "Cloth"
ITEM.model = "models/props_junk/vent001_chunk8.mdl"
ITEM.combineRemove = true -- consume the bread
ITEM.combineGive = "bandage"
ITEM.combineSound = "foley/alyx_hug_eli.wav"
ITEM.combineThings = {"thread"} -- either works
ITEM.width = 2
ITEM.height = 2


ITEM.functions.combine = {
    OnRun = function(item, data)
        local client = item.player
        local target = ix.item.instances[data and data[1]]
        if not (IsValid(client) and target) then return false end

        local char = client:GetCharacter()
        local inv = char and char:GetInventory()
        if not (inv and item.combineThings) then return false end

        for _, id in ipairs(item.combineThings) do
            if target.uniqueID == id then
                local movementKeys = {
                    [KEY_W] = true,
                    [KEY_A] = true,
                    [KEY_S] = true,
                    [KEY_D] = true,
                    [KEY_SPACE] = true,
                    [KEY_LSHIFT] = true
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

                client:SetAction("Combining items...", 1.9, function()
                    hook.Remove("PlayerButtonDown", cancelHook)
                    if canceled then return end

                    if item.combineSound then client:EmitSound(item.combineSound) end

                    local give = item.combineGive
                    if give then
                        if istable(give) then
                            for _, g in ipairs(give) do
                                if not inv:Add(g) then
                                    client:Notify("Not enough space for " .. g .. ".")
                                    return
                                end
                            end
                        else
                            if not inv:Add(give) then
                                client:Notify("Not enough space for " .. give .. ".")
                                return
                            end
                        end
                    end

                    if item.combineRemove then item:Remove() end
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
