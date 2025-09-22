
ITEM.name = "Pot";
ITEM.model = "models/props_c17/metalPot001a.mdl";
ITEM.width	= 2
ITEM.height	= 3
ITEM.description = "The solution and the problem."
ITEM.category = "Containers"
ITEM.capacity = 1500

ITEM.functions.Boil = {
    name = "Boil",
    icon = "icon16/fire.png",
    OnRun = function(item)
        local client = item.player

        client:EmitSound("ambient/water/underwater.wav", 35, 190, 1, CHAN_STATIC)

        local cancelHook = "ixBoilCancel_" .. client:SteamID()
        local canceled = false
        local movementKeys = {
            [KEY_W] = true, [KEY_A] = true, [KEY_S] = true, [KEY_D] = true,
            [KEY_SPACE] = true, [KEY_LSHIFT] = true
        }

        hook.Add("PlayerButtonDown", cancelHook, function(ply, button)
            if ply == client and movementKeys[button] then
                canceled = true
                client:SetAction()
                client:StopSound("ambient/water/underwater.wav")
                client:Notify("You moved and canceled boiling.")
                hook.Remove("PlayerButtonDown", cancelHook)
            end
        end)

        client:SetAction("Boiling water...", 10, function()
            hook.Remove("PlayerButtonDown", cancelHook)
            client:StopSound("ambient/water/underwater.wav")
            if canceled then return end

            item:SetLiquid("water")
            item:SetVolume(math.floor(item:GetVolume() * 0.8))
            client:Notify("Water boiled.")
        end)

        return false
    end,
    OnCanRun = function(item)
        if not IsValid(item.entity) then return false end
        if item:GetLiquid() ~= "waterraw" then return false end

        for _, ent in ipairs(ents.FindInSphere(item.entity:GetPos(), 100)) do
            if ent:GetClass() == "ix_cookingsource" then
                return true
            end
        end

        return false
    end
}
