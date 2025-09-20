AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Stove"
ENT.Category = "Helix"
ENT.Spawnable = true

if SERVER then
    util.AddNetworkString("ixStovePlacePan")
    util.AddNetworkString("ixStoveRemovePan")
    util.AddNetworkString("ixStoveCook")

    function ENT:Initialize()
        self:SetModel("models/props_c17/furnitureStove001a.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetUseType(SIMPLE_USE)

        local phys = self:GetPhysicsObject()
        if IsValid(phys) then phys:Wake() end

        self.storedPanID = nil -- holds the item ID of the pan
    end

    -- Place Pan
    net.Receive("ixStovePlacePan", function(_, client)
        local ent = net.ReadEntity()
        if not IsValid(ent) or ent:GetClass() ~= "ix_stove" then return end

        local char = client:GetCharacter()
        if not char then return end
        local inv = char:GetInventory()

        local panItem = inv:HasItem("pan")
        if not panItem then
            client:Notify("You don't have a pan.")
            return
        end

        ent.storedPanID = panItem.id
        inv:Remove(panItem.id)

        client:Notify("You placed your pan on the stove.")
    end)

    -- Remove Pan
    net.Receive("ixStoveRemovePan", function(_, client)
        local ent = net.ReadEntity()
        if not IsValid(ent) or ent:GetClass() ~= "ix_stove" then return end

        local char = client:GetCharacter()
        if not char then return end
        local inv = char:GetInventory()

        if ent.storedPanID then
            local item = ix.item.instances[ent.storedPanID]
            if item then
                inv:Add(item.uniqueID, 1, item.data)
                client:Notify("You took your pan back.")
            end
        end

        ent.storedPanID = nil
    end)

    -- Cook Recipe
    net.Receive("ixStoveCook", function(_, client)
        local ent = net.ReadEntity()
        local recipeName = net.ReadString()
        if not IsValid(ent) or ent:GetClass() ~= "ix_stove" then return end

        local recipes = {
            ["Fried Egg"] = {ingredients = {"egg"}, result = "fried_egg", time = 3},
            ["Omelette"] = {ingredients = {"egg", "egg", "milk"}, result = "omelette", time = 4},
            ["Steak"] = {ingredients = {"raw_meat"}, result = "cooked_steak", time = 5},
            -- add more recipes here
        }

        local recipe = recipes[recipeName]
        if not recipe then return end

        local char = client:GetCharacter()
        if not char then return end
        local inv = char:GetInventory()

        local items = {}
        for _, id in ipairs(recipe.ingredients) do
            local item = inv:HasItem(id)
            if not item then
                client:Notify("Missing ingredient: " .. id)
                return
            end
            table.insert(items, item)
        end

        -- Movement cancel logic
        local movementKeys = {
            [KEY_W] = true, [KEY_A] = true, [KEY_S] = true, [KEY_D] = true,
            [KEY_SPACE] = true, [KEY_LSHIFT] = true
        }
        local cancelHook = "ixCookCancel_" .. client:SteamID()
        local canceled = false

        hook.Add("PlayerButtonDown", cancelHook, function(ply, button)
            if ply == client and movementKeys[button] then
                canceled = true
                client:SetAction()
                client:Notify("You moved and canceled cooking.")
                hook.Remove("PlayerButtonDown", cancelHook)
            end
        end)

        client:SetAction("Cooking " .. recipeName .. "...", recipe.time, function()
            hook.Remove("PlayerButtonDown", cancelHook)
            if canceled then return end

            for _, item in ipairs(items) do inv:Remove(item.id) end
            inv:Add(recipe.result)
            client:Notify("You cooked " .. recipeName .. "!")
        end)
    end)
end

-- CLIENT: Menu
function ENT:GetEntityMenu(client)
    local options = {}
    local char = client:GetCharacter()
    if not char then return options end
    local inv = char:GetInventory()

    if not self.storedPanID then
        if inv:HasItem("pan") then
            options["Place Pan"] = function()
                net.Start("ixStovePlacePan")
                    net.WriteEntity(self)
                net.SendToServer()
            end
        end
    else
        options["Remove Pan"] = function()
            net.Start("ixStoveRemovePan")
                net.WriteEntity(self)
            net.SendToServer()
        end

        local recipes = {
            ["Fried Egg"] = {"egg"},
            ["Omelette"] = {"egg", "egg", "milk"},
            ["Steak"] = {"raw_meat"}
        }

        local cookOptions = {}
        for name, ingredients in pairs(recipes) do
            local valid = true
            for _, id in ipairs(ingredients) do
                if not inv:HasItem(id) then valid = false break end
            end
            if valid then
                cookOptions[name] = function()
                    net.Start("ixStoveCook")
                        net.WriteEntity(self)
                        net.WriteString(name)
                    net.SendToServer()
                end
            end
        end

        if next(cookOptions) then
            options["Cook"] = cookOptions
        end
    end

    return options
end