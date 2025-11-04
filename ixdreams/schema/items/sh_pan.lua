ITEM.name = "Pan"
ITEM.description = "Pan."
ITEM.model = "models/props_c17/metalPot002a.mdl"
ITEM.category = "Utility"
ITEM.width = 2
ITEM.height = 2

ITEM.functions.CookToastBread = {
    name = "Toast Bread",
    OnRun = function(item)
        local client = item.player
        local inv = client:GetCharacter():GetInventory()

        client:EmitSound("ambient/fire/fire_small_loop2.wav", 30, 150, 1, CHAN_STATIC)

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
                client:StopSound("ambient/fire/fire_small_loop2.wav")
                hook.Remove("PlayerButtonDown", cancelHook)
            end
        end)

        client:SetAction("Toasting bread...", 3, function()
            hook.Remove("PlayerButtonDown", cancelHook)
            client:StopSound("ambient/fire/fire_small_loop2.wav")
            if canceled then return end

            local bread = inv:HasItem("breadslice")
            if not bread then return end

            inv:Remove(bread.id)
            inv:Add("breadslicetoast")
        end)

        return false
    end,
    OnCanRun = function(item)
        if not IsValid(item.entity) then return false end

        local char = item.player:GetCharacter()
        local inv = char and char:GetInventory()
        if not inv or not inv:HasItem("breadslice") then
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

ITEM.functions.CookEgg = {
    name = "Fry Egg",
    OnRun = function(item)
        local client = item.player
        local inv = client:GetCharacter():GetInventory()

        client:EmitSound("ambient/fire/fire_small_loop2.wav", 30, 150, 1, CHAN_STATIC)

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
                client:StopSound("ambient/fire/fire_small_loop2.wav")
                hook.Remove("PlayerButtonDown", cancelHook)
            end
        end)

        client:SetAction("Frying Egg...", 3, function()
            hook.Remove("PlayerButtonDown", cancelHook)
            client:StopSound("ambient/fire/fire_small_loop2.wav")
            if canceled then return end

            local egg = inv:HasItem("egg")
            if not egg then return end

            inv:Remove(egg.id)
            inv:Add("eggcooked")
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



ITEM.functions.CookRamen = {
    name = "Cook Ramen",
    OnRun = function(item)
        local client = item.player
        local inv = client:GetCharacter():GetInventory()
        local ramen = inv:HasItem("ramennoodles")
        if not ramen then return false end

        client:SetAction("Cooking ramen...", 3, function()
            ramen:SetData("cooked", 10)
            client:Notify("You cooked ramen noodles!")
        end)

        return false
    end,
    OnCanRun = function(item)
        if not IsValid(item.entity) then return false end
        local char = item.player:GetCharacter()
        local inv = char and char:GetInventory()
        if not inv or not inv:HasItem("ramennoodles") then return false end

        for _, ent in ipairs(ents.FindInSphere(item.entity:GetPos(), 100)) do
            if ent:GetClass() == "ix_cookingsource" then
                return true
            end
        end

        return false
    end
}

ITEM.functions.CookLeech = {
    name = "Cook Leech",
    OnRun = function(item)
        local client = item.player
        local inv = client:GetCharacter():GetInventory()
        local leech = inv:HasItem("leech")
        if not leech then return false end

        client:EmitSound("ambient/fire/fire_small_loop2.wav", 30, 150, 1, CHAN_STATIC)

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
                client:StopSound("ambient/fire/fire_small_loop2.wav")
                hook.Remove("PlayerButtonDown", cancelHook)
            end
        end)

        client:SetAction("Cooking leech...", 3, function()
            hook.Remove("PlayerButtonDown", cancelHook)
            client:StopSound("ambient/fire/fire_small_loop2.wav")
            if canceled then return end
            
            leech:SetData("cooked", 10)
            
            client:Notify("You cooked a leech!")
        end)

        return false
    end,
    OnCanRun = function(item)
        if not IsValid(item.entity) then return false end
        local char = item.player:GetCharacter()
        local inv = char and char:GetInventory()
        if not inv or not inv:HasItem("leech") then return false end

        for _, ent in ipairs(ents.FindInSphere(item.entity:GetPos(), 100)) do
            if ent:GetClass() == "ix_cookingsource" then
                return true
            end
        end

        return false
    end
}

ITEM.functions.CookHeadcrab = {
    name = "Cook Headcrab",
    OnRun = function(item)
        local client = item.player
        local inv = client:GetCharacter():GetInventory()
        local headcrab = inv:HasItem("headcrabgib")
        if not headcrab then return false end

        client:EmitSound("ambient/fire/fire_small_loop2.wav", 30, 150, 1, CHAN_STATIC)

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
                client:StopSound("ambient/fire/fire_small_loop2.wav")
                hook.Remove("PlayerButtonDown", cancelHook)
            end
        end)

        client:SetAction("Cooking headcrab...", 3, function()
            hook.Remove("PlayerButtonDown", cancelHook)
            client:StopSound("ambient/fire/fire_small_loop2.wav")
            if canceled then return end
            
            headcrab:SetData("cooked", 10)
        end)

        return false
    end,
    OnCanRun = function(item)
        if not IsValid(item.entity) then return false end
        local char = item.player:GetCharacter()
        local inv = char and char:GetInventory()
        if not inv or not inv:HasItem("headcrabgib") then return false end

        for _, ent in ipairs(ents.FindInSphere(item.entity:GetPos(), 100)) do
            if ent:GetClass() == "ix_cookingsource" then
                return true
            end
        end

        return false
    end
}

ITEM.functions.Cookredmeat = {
    name = "Cook Red Meat",
    OnRun = function(item)
        local client = item.player
        local inv = client:GetCharacter():GetInventory()
        local food = inv:HasItem("meathuman")
        if not food then return false end

        client:EmitSound("ambient/fire/fire_small_loop2.wav", 30, 150, 1, CHAN_STATIC)

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
                client:StopSound("ambient/fire/fire_small_loop2.wav")
                hook.Remove("PlayerButtonDown", cancelHook)
            end
        end)

        client:SetAction("Cooking headcrab...", 3, function()
            hook.Remove("PlayerButtonDown", cancelHook)
            client:StopSound("ambient/fire/fire_small_loop2.wav")
            if canceled then return end
            
            food:SetData("cooked", 10)
        end)

        return false
    end,
    OnCanRun = function(item)
        if not IsValid(item.entity) then return false end
        local char = item.player:GetCharacter()
        local inv = char and char:GetInventory()
        if not inv or not inv:HasItem("meathuman") then return false end

        for _, ent in ipairs(ents.FindInSphere(item.entity:GetPos(), 100)) do
            if ent:GetClass() == "ix_cookingsource" then
                return true
            end
        end

        return false
    end
}