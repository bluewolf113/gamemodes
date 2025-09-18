PLUGIN.name = "Nutscript-like Item Menu"
PLUGIN.author = "gumlefar"
PLUGIN.desc = "Replaces the default Helix item interaction menu."

ix.menu = ix.menu or {}
ix.menu.list = ix.menu.list or {}

-- OVERRIDE
if (CLIENT) then
    function ix.menu.Open(options, entity)
        if (IsValid(ix.menu.panel)) then
            return false
        end
    
        ix.menu.AddToList(options, entity)
    
        return true
    end

    surface.CreateFont("ixItemMenuFont", {
        font = "Consolas",
        size = 20,
        extended = true,
        weight = 500
    })
end

-- Adds a new menu to the list of drawn menus.
function ix.menu.AddToList(options, position, onRemove)
    local width = 0
    local entity    

    surface.SetFont("ixItemMenuFont")

    for k, v in pairs(options) do
        width = math.max(width, surface.GetTextSize(tostring(k)))
    end

    if (type(position) == "Entity") then
        entity = position
        position = entity:WorldToLocal(LocalPlayer():GetEyeTrace().HitPos)
    end

    for k,v in pairs(ix.menu.list) do
        if v.entity == entity then return -1 end
    end

    return table.insert(ix.menu.list, {
        position = position or LocalPlayer():GetEyeTrace().HitPos,
        options = options,
        width = width + 8,
        height = table.Count(options) * 28,
        entity = entity,
        onRemove = isfunction(onRemove) and onRemove or nil -- Ensure it's a function or nil
    })
end

-- Draw all active menus.
function ix.menu.DrawAll()
    local frameTime = FrameTime() * 30
    local mX, mY = ScrW() * 0.5, ScrH() * 0.5
    local position2 = LocalPlayer():GetPos()

    for k, v in ipairs(ix.menu.list) do
        local position
        local entity = v.entity

        if (IsValid(entity)) then
            local realPos = entity:LocalToWorld(v.position)
            v.entPos = LerpVector(frameTime * 0.5, v.entPos or realPos, realPos)
            position = v.entPos:ToScreen()
        elseif (v.position) then
            position = v.position:ToScreen()
        else
            table.remove(ix.menu.list, k)
            if (v.onRemove) then v.onRemove() end
            continue
        end

        local width, height = v.width, v.height
        local startX, startY = position.x - (width * 0.5), position.y
        local alpha = v.alpha or 0
        local inRange = position2:DistToSqr(IsValid(entity) and entity:GetPos() or v.position) <= 9216
        local inside = (mX >= startX and mX <= (startX + width) and mY >= startY and mY <= (startY + height)) and inRange

        if (!v.displayed or inside) then
            v.alpha = math.Approach(alpha, 255, frameTime * 25)
            if (v.alpha == 255) then v.displayed = true end
        else
            v.alpha = math.Approach(alpha, 0, inRange and frameTime or (frameTime * 45))
            if (v.alpha == 0) then
                table.remove(ix.menu.list, k)
                if (v.onRemove) then v.onRemove() end
                continue
            end
        end

        local i = 0
        local x2, y2, w2, h2 = startX - 4, startY - 4, width + 8, height + 8
        alpha = v.alpha * 0.9

        surface.SetDrawColor(40, 40, 40, alpha)
        surface.DrawRect(x2, y2, w2, h2)
        surface.SetDrawColor(250, 250, 250, alpha * 0.025)
        surface.DrawTexturedRect(x2, y2, w2, h2)
        surface.SetDrawColor(0, 0, 0, alpha * 0.25)
        surface.DrawOutlinedRect(x2, y2, w2, h2)

        for k2, v2 in SortedPairs(v.options) do
            local y = startY + (i * 28)
            if (inside and mY >= y and mY <= (y + 28)) then
                surface.SetDrawColor(ColorAlpha(ix.config.Get("color"), v.alpha + math.cos(RealTime() * 8) * 40))
                surface.DrawRect(startX, y, width, 28)
            end
            ix.util.DrawText(k2, startX + 4, y + 1, ColorAlpha(color_white, v.alpha), nil, nil, "ixItemMenuFont")
            i = i + 1
        end
    end
end

function PLUGIN:HUDPaint()
    ix.menu.DrawAll()
end

function ix.menu.OnButtonPressed(menu, callback)
    table.remove(ix.menu.list, menu)

    if (isfunction(callback)) then
        callback()
        return true
    end

    return false
end

function ix.menu.GetActiveMenu()
    local mX, mY = ScrW() * 0.5, ScrH() * 0.5
    local position2 = LocalPlayer():GetPos()

    for k, v in ipairs(ix.menu.list) do
        local position
        local entity = v.entity
        local width, height = v.width, v.height

        if (IsValid(entity)) then
            position = (v.entPos or entity:LocalToWorld(v.position)):ToScreen()
        else
            table.remove(ix.menu.list, k)
            continue
        end

        local startX, startY = position.x - (width * 0.5), position.y
        local inRange = position2:Distance(IsValid(entity) and entity:GetPos() or v.position) <= 96
        local inside = (mX >= startX and mX <= (startX + width) and mY >= startY and mY <= (startY + height)) and inRange

        if (inRange and inside) then
            local choice
            local i = 0

            for k2, v2 in SortedPairs(v.options) do
                local y = startY + (i * 28)
                if (inside and mY >= y and mY <= (y + 28)) then
                    choice = v2
                    break
                end
                i = i + 1
            end

            return k, choice
        end
    end
end

if CLIENT then 
    function PLUGIN:PlayerBindPress(client, bind, pressed)
        if ((bind:find("use") or bind:find("attack")) and pressed) then
            local menu, callback = ix.menu.GetActiveMenu()
            if (menu and ix.menu.OnButtonPressed(menu, callback)) then
                return true
            end
        end
    end
end
