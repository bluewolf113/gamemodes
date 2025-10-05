local PLUGIN = PLUGIN

PLUGIN.name = "Injuries"
PLUGIN.author = "blue"
PLUGIN.description = "Unified injury system with modular injury files."

PLUGIN.injuries = {}

-- =========================
-- Framework functions
-- =========================
function PLUGIN:ApplyInjury(ply, injury)
    local def = self.injuries[injury]
    if not def or ply:GetNetVar(injury) then return end
    ply:SetNetVar(injury, true)
    if def.enter then def.enter(ply) end
end

function PLUGIN:RemoveInjury(ply, injury)
    local def = self.injuries[injury]
    if not def or not ply:GetNetVar(injury) then return end
    ply:SetNetVar(injury, nil)
    if def.exit then def.exit(ply) end
end

function PLUGIN:ClearAllInjuries(ply)
    for injury, _ in pairs(self.injuries) do
        if ply:GetNetVar(injury) then
            self:RemoveInjury(ply, injury)
        end
    end
end

-- =========================
-- Hooks
-- =========================
function PLUGIN:EntityTakeDamage(target, dmgInfo)
    if not IsValid(target) or not target:IsPlayer() then return end

    local hg = target:LastHitGroup() or HITGROUP_GENERIC
    local dt = dmgInfo:GetDamageType()

    for injury, def in pairs(self.injuries) do
        if def.condition and def.condition(target, dmgInfo, hg, dt) then
            self:ApplyInjury(target, injury)
        end
    end
end

function PLUGIN:PlayerDeath(ply)
    self:ClearAllInjuries(ply)
end

-- =========================
-- Commands
-- =========================
ix.command.Add("AddInjury", {
    description = "Apply an injury to yourself or another player.",
    arguments = {ix.type.string, bit.bor(ix.type.player, ix.type.optional)},
    OnRun = function(self, client, injury, target)
        local ply = target or client
        local plugin = ix.plugin.list["injuries"]
        if not plugin or not plugin.injuries[injury] then
            return "Invalid injury: " .. injury
        end
        plugin:ApplyInjury(ply, injury)
        return "Applied injury '" .. injury .. "' to " .. ply:Name()
    end
})

ix.command.Add("RemoveInjury", {
    description = "Remove an injury from yourself or another player.",
    arguments = {ix.type.string, bit.bor(ix.type.player, ix.type.optional)},
    OnRun = function(self, client, injury, target)
        local ply = target or client
        local plugin = ix.plugin.list["injuries"]
        if not plugin or not plugin.injuries[injury] then
            return "Invalid injury: " .. injury
        end
        plugin:RemoveInjury(ply, injury)
        return "Removed injury '" .. injury .. "' from " .. ply:Name()
    end
})

ix.command.Add("CheckInjuries", {
    description = "Check which injuries a player currently has.",
    arguments = {bit.bor(ix.type.player, ix.type.optional)},
    OnRun = function(self, client, target)
        local ply = target or client
        local plugin = ix.plugin.list["injuries"]
        if not plugin then return "Injuries plugin not loaded." end

        local active = {}
        for injury, _ in pairs(plugin.injuries) do
            if ply:GetNetVar(injury) then
                table.insert(active, injury)
            end
        end

        if #active == 0 then
            return ply:Name() .. " has no active injuries."
        else
            return ply:Name() .. " has: " .. table.concat(active, ", ")
        end
    end
})

ix.command.Add("ClearAllInjuries", {
    description = "Remove all injuries from yourself or another player.",
    arguments = {bit.bor(ix.type.player, ix.type.optional)},
    OnRun = function(self, client, target)
        local ply = target or client
        local plugin = ix.plugin.list["injuries"]
        if not plugin then return "Injuries plugin not loaded." end
        plugin:ClearAllInjuries(ply)
        return "Cleared all injuries from " .. ply:Name()
    end
})

-- =========================
-- Load all injury files
-- =========================
ix.util.IncludeDir(PLUGIN.folder .. "/injuries", true)

-- =========================
-- Character meta
-- =========================
do
    local charMeta = ix.meta.character

    function charMeta:AddInjury(injury)
        local client = self:GetPlayer()
        if not IsValid(client) then return end

        local plugin = ix.plugin.list["injuries"]
        if plugin then
            plugin:ApplyInjury(client, injury)
        end
    end

    function charMeta:RemoveInjury(injury)
        local client = self:GetPlayer()
        if not IsValid(client) then return end

        local plugin = ix.plugin.list["injuries"]
        if plugin then
            plugin:RemoveInjury(client, injury)
        end
    end

    function charMeta:HasInjury(injury)
        local client = self:GetPlayer()
        if not IsValid(client) then return false end
        return client:GetNetVar(injury) == true
    end
end

if CLIENT then
    net.Receive("ixInjuryFlash", function()
        local flash = vgui.Create("DPanel")
        flash:SetSize(ScrW(), ScrH())
        flash:SetBackgroundColor(Color(0, 0, 0))
        flash:SetAlpha(0)
        flash:AlphaTo(85, 0.1, 0, function()
            flash:AlphaTo(0, 1.0, 0.2, function() flash:Remove() end)
        end)
    end)
end
