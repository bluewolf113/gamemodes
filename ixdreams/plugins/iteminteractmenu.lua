PLUGIN.name = "Nutscript-like Item Menu"
PLUGIN.author = "gumlefar"
PLUGIN.desc = "Replaces the default awful Helix item interaction menu."

ix.menu = ix.menu or {}
ix.menu.list = ix.menu.list or {}

ix.option.Add("menuTheme", ix.type.array, "Half Life", {
    category = "Appearance",
    name = "Menu Theme",
    description = "Choose a color theme for your interaction menus.",
    populate = function()
        local entries = {}

        entries["Half Life"] = "Half Life (Orange)"
        entries["Dark"] = "Dark (Gray)"
        entries["DOS Style"] = "DOS Style (Green)"

        return entries
    end
})


-- =========================================================
-- CLIENT
-- =========================================================
if CLIENT then
    -- Unique net channel for entity option dispatch
    local NET_ENTITY_OPTION = "ixMenuEntityOption"

    -- Backup original Helix open if not already
    ix.menu.OpenDefault = ix.menu.OpenDefault or ix.menu.Open

    -- Normalize options to callbacks:
    -- - function: kept as-is
    -- - boolean true: server dispatch to ent:OnOptionSelected(client, label, nil)
    -- - table: {callback=true|function, data=?}
    function ix.menu.NormalizeOptions(options, entity)
        local normalized = {}

        for label, val in pairs(options or {}) do
            local t = type(val)

            if t == "function" then
                normalized[label] = val

            elseif t == "boolean" then
                normalized[label] = function()
                    if not IsValid(entity) then return end
                    net.Start(NET_ENTITY_OPTION)
                        net.WriteEntity(entity)
                        net.WriteString(label)
                        net.WriteBool(false) -- hasData
                    net.SendToServer()
                end

            elseif t == "table" then
                local cb = val.callback
                local data = val.data

                if type(cb) == "function" then
                    normalized[label] = function()
                        cb(LocalPlayer(), entity, data)
                    end
                else
                    normalized[label] = function()
                        if not IsValid(entity) then return end
                        net.Start(NET_ENTITY_OPTION)
                            net.WriteEntity(entity)
                            net.WriteString(label)
                            local hasData = data ~= nil
                            net.WriteBool(hasData)
                            if hasData then
                                net.WriteTable(data)
                            end
                        net.SendToServer()
                    end
                end
            end
        end

        return normalized
    end

    function ix.menu.Open(options, entity)
        -- Prevent opening multiple default Helix panels
        if IsValid(ix.menu.panel) then
            return false
        end

        -- If the entity is a player, use Helix's default menu
        if IsValid(entity) and entity:IsPlayer() then
            return ix.menu.OpenDefault(options, entity)
        end

        -- Normalize and add to our floating menu list
        local normalized = ix.menu.NormalizeOptions(options, entity)
        ix.menu.AddToList(normalized, entity)

        return true
    end

    surface.CreateFont("ixItemMenuFont", {
        font = "Consolas",
        size = 20,
        extended = true,
        weight = 500
    })
end

-- =========================================================
-- MENU LIST MANAGEMENT + DRAW
-- =========================================================
function ix.menu.AddToList(options, position, onRemove)
    local width = 0
    local entity

    surface.SetFont("ixItemMenuFont")

    for k, _ in pairs(options) do
        width = math.max(width, surface.GetTextSize(tostring(k)))
    end

    -- Attach to entity if provided
    if type(position) == "Entity" then
        entity = position
        position = entity:WorldToLocal(LocalPlayer():GetEyeTrace().HitPos)
    end

    -- Prevent duplicates on same entity
    for _, v in pairs(ix.menu.list) do
        if v.entity == entity then return -1 end
    end

    return table.insert(ix.menu.list, {
        position = position or LocalPlayer():GetEyeTrace().HitPos,
        options = options,
        width = width + 8,
        height = table.Count(options) * 28,
        entity = entity,
        onRemove = onRemove
    })
end

function ix.menu.DrawAll()
    local frameTime = FrameTime() * 30
    local mX, mY = ScrW() * 0.5, ScrH() * 0.5
    local position2 = LocalPlayer():GetPos()

    for k, v in ipairs(ix.menu.list) do
        local position
        local entity = v.entity

        if entity then
            if IsValid(entity) then
                local realPos = entity:LocalToWorld(v.position)
                v.entPos = LerpVector(frameTime * 0.5, v.entPos or realPos, realPos)
                position = v.entPos:ToScreen()
            else
                table.remove(ix.menu.list, k)
                if v.onRemove then v:onRemove() end
                continue
            end
        else
            position = v.position:ToScreen()
        end

        local width, height = v.width, v.height
        local startX, startY = position.x - (width * 0.5), position.y
        local alpha = v.alpha or 0

        -- Keep radius consistent with your menu (96 units)
        local inRange = position2:DistToSqr(IsValid(entity) and entity:GetPos() or v.position) <= 9216
        local inside = (mX >= startX and mX <= (startX + width) and mY >= startY and mY <= (startY + height)) and inRange

        if not v.displayed or inside then
            v.alpha = math.Approach(alpha or 0, 255, frameTime * 25)
            if v.alpha == 255 then v.displayed = true end
        else
            v.alpha = math.Approach(alpha or 0, 0, inRange and frameTime or (frameTime * 45))
            if v.alpha == 0 then
                table.remove(ix.menu.list, k)
                if v.onRemove then v:onRemove() end
                continue
            end
        end

        local i = 0
        local x2, y2, w2, h2 = startX - 4, startY - 4, width + 8, height + 8
        alpha = v.alpha * 0.9
        --color stuff
        local theme = ix.option.Get("menuTheme", "Half Life")
        local themeColors = {
            ["Half Life"] = Color(251, 126, 20, 90),   -- orange
            ["Dark"] = Color(40, 40, 40, 180),         -- muted gray
            ["DOS Style"] = Color(0, 255, 0, 120)      -- neon green
        }

        local color = themeColors[theme] or Color(251, 126, 20, 90)
        surface.SetDrawColor(color)
        surface.DrawRect(x2, y2, w2, h2)

        surface.SetDrawColor(250, 250, 250, alpha * 0.025)
        surface.DrawTexturedRect(x2, y2, w2, h2)

        surface.SetDrawColor(0, 0, 0, alpha * 0.25)
        surface.DrawOutlinedRect(x2, y2, w2, h2)

        for label, callback in SortedPairs(v.options) do
            local y = startY + (i * 28)

            if inside and mY >= y and mY <= (y + 28) then
                surface.SetDrawColor(ColorAlpha(ix.config.Get("color"), v.alpha + math.cos(RealTime() * 8) * 40))
                surface.DrawRect(startX, y, width, 28)
            end

            ix.util.DrawText(label, startX + 4, y + 1, ColorAlpha(color_white, v.alpha), nil, nil, "ixItemMenuFont")
            i = i + 1
        end
    end
end

function PLUGIN:HUDPaint()
    ix.menu.DrawAll()
end

function ix.menu.OnButtonPressed(menuIndex, callback)
    local entry = ix.menu.list[menuIndex]
    table.remove(ix.menu.list, menuIndex)

    if type(callback) == "function" then
        -- Pass player and entity for client callbacks
        callback(LocalPlayer(), entry and entry.entity)
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

        if entity then
            if IsValid(entity) then
                position = (v.entPos or entity:LocalToWorld(v.position)):ToScreen()
            else
                table.remove(ix.menu.list, k)
                continue
            end
        else
            position = v.position:ToScreen()
        end

        local startX, startY = position.x - (width * 0.5), position.y
        local inRange = position2:Distance(IsValid(entity) and entity:GetPos() or v.position) <= 96
        local inside = (mX >= startX and mX <= (startX + width) and mY >= startY and mY <= (startY + height)) and inRange

        if inRange and inside then
            local choice
            local i = 0

            for _, v2 in SortedPairs(v.options) do
                local y = startY + (i * 28)
                if inside and mY >= y and mY <= (y + 28) then
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

-- =========================================================
-- SERVER BRIDGE
-- =========================================================
if SERVER then
    util.AddNetworkString("ixMenuEntityOption")

    local function inUseRange(ply, ent)
        if not (IsValid(ply) and IsValid(ent)) then return false end
        -- Match your menu radius (96 units). If your entity uses 75, change here.
        return ply:GetPos():DistToSqr(ent:GetPos()) <= (96 * 96)
    end

    net.Receive("ixMenuEntityOption", function(_, client)
        local ent = net.ReadEntity()
        local label = net.ReadString()
        local hasData = net.ReadBool()
        local data = hasData and net.ReadTable() or nil

        if not (IsValid(client) and IsValid(ent)) then return end
        if not client:GetCharacter() then return end
        if not inUseRange(client, ent) then return end
        if not isfunction(ent.OnOptionSelected) then return end

        -- Delegate to entity's server-side logic (like your radio)
        ent:OnOptionSelected(client, label, data)
    end)
end
