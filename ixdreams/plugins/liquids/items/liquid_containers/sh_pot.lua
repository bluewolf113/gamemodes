
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


ITEM.functions.BoilEgg = {
    name = "Boil Egg",
    OnRun = function(item)
        local client = item.player
        local inv = client:GetCharacter():GetInventory()

        client:EmitSound("ambient/water/underwater.wav", 35, 190, 1, CHAN_STATIC)

        local cancelHook = "ixCookCancel_" .. client:SteamID()
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
                hook.Remove("PlayerButtonDown", cancelHook)
            end
        end)

        client:SetAction("Boiling Egg...", 3, function()
            hook.Remove("PlayerButtonDown", cancelHook)
            client:StopSound("ambient/water/underwater.wav")
            if canceled then return end

            local egg = inv:HasItem("egg")
            if not egg then return end

            inv:Remove(egg.id)
            inv:Add("eggboiled")
            item:SetVolume(math.floor(item:GetVolume() * 0.8))
        end)

        return false
    end,
    OnCanRun = function(item)
        if not IsValid(item.entity) then return false end

        local char = item.player:GetCharacter()
        local inv = char and char:GetInventory()
        if not inv or not inv:HasItem("egg") then
            return false
        end

        -- must be near a cooking source
        local nearSource = false
        for _, ent in ipairs(ents.FindInSphere(item.entity:GetPos(), 100)) do
            if ent:GetClass() == "ix_cookingsource" then
                nearSource = true
                break
            end
        end

        return nearSource
    end
}

ITEM.functions.Boilchumtoad = {
    name = "Boil eye of Chumtoad",
    OnRun = function(item)
        local client = item.player
        local inv = client:GetCharacter():GetInventory()
        local food = inv:HasItem("chumtoadseye")
        if not food then return false end

        client:EmitSound("ambient/water/underwater.wav", 35, 190, 1, CHAN_STATIC)

        local cancelHook = "ixCookCancel_" .. client:SteamID()
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
                hook.Remove("PlayerButtonDown", cancelHook)
            end
        end)

        client:SetAction("Boiling eye of Chumtoad...", 3, function()
            hook.Remove("PlayerButtonDown", cancelHook)
            client:StopSound("ambient/water/underwater.wav")
            if canceled then return end
            
            food:SetData("cooked", 10)
        end)

        return false
    end,
    OnCanRun = function(item)
        if not IsValid(item.entity) then return false end
        local char = item.player:GetCharacter()
        local inv = char and char:GetInventory()
        if not inv or not inv:HasItem("chumtoadseye") then return false end

        for _, ent in ipairs(ents.FindInSphere(item.entity:GetPos(), 100)) do
            if ent:GetClass() == "ix_cookingsource" then
                return true
            end
        end

        return false
    end
}

ITEM.functions.Boilantlion = {
    name = "Boil Antlion's Leg",
    OnRun = function(item)
        local client = item.player
        local inv = client:GetCharacter():GetInventory()
        local food = inv:HasItem("antlionleg")
        if not food then return false end

        client:EmitSound("ambient/water/underwater.wav", 35, 190, 1, CHAN_STATIC)

        local cancelHook = "ixCookCancel_" .. client:SteamID()
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
                hook.Remove("PlayerButtonDown", cancelHook)
            end
        end)

        client:SetAction("Boiling Antlion's Leg...", 3, function()
            hook.Remove("PlayerButtonDown", cancelHook)
            client:StopSound("ambient/water/underwater.wav")
            if canceled then return end
            
            food:SetData("cooked", 10)
        end)

        return false
    end,
    OnCanRun = function(item)
        if not IsValid(item.entity) then return false end
        local char = item.player:GetCharacter()
        local inv = char and char:GetInventory()
        if not inv or not inv:HasItem("antlionleg") then return false end

        for _, ent in ipairs(ents.FindInSphere(item.entity:GetPos(), 100)) do
            if ent:GetClass() == "ix_cookingsource" then
                return true
            end
        end

        return false
    end
}

ITEM.functions.Boilpotatomash = {
    name = "Boil and Mash Potato",
    OnRun = function(item)
        local client = item.player
        local inv = client:GetCharacter():GetInventory()

        client:EmitSound("ambient/water/underwater.wav", 35, 190, 1, CHAN_STATIC)

        local cancelHook = "ixCookCancel_" .. client:SteamID()
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
                hook.Remove("PlayerButtonDown", cancelHook)
            end
        end)

        client:SetAction("Preparing mashed potatoes...", 3, function()
            hook.Remove("PlayerButtonDown", cancelHook)
            client:StopSound("ambient/water/underwater.wav")
            if canceled then return end

            local food = inv:HasItem("potato")
            if not food then return end

            inv:Remove(egg.id)
            inv:Add("potatomash")
            item:SetVolume(math.floor(item:GetVolume() * 0.8))
        end)

        return false
    end,
    OnCanRun = function(item)
        if not IsValid(item.entity) then return false end

        local char = item.player:GetCharacter()
        local inv = char and char:GetInventory()
        if not inv or not inv:HasItem("potato") then
            return false
        end

        -- must be near a cooking source
        local nearSource = false
        for _, ent in ipairs(ents.FindInSphere(item.entity:GetPos(), 100)) do
            if ent:GetClass() == "ix_cookingsource" then
                nearSource = true
                break
            end
        end

        return nearSource
    end
}