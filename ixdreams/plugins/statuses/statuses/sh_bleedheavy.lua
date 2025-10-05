local PLUGIN = PLUGIN
local STATUS = {}

STATUS.name = "Bleeding (Heavy)"
STATUS.uniqueID = "bleedingheavy"

-- Trigger on bullet, club, or slash damage
STATUS.condition = function(ply, dmgInfo, hitgroup, dt)
    return bit.band(dt, bit.bor(DMG_BULLET, DMG_CLUB, DMG_SLASH)) ~= 0
        and math.random(9) == 1
end

function STATUS:OnApply(client, scaleFactor)
    client:Notify("You are bleeding!")

    local id = "ixBleedingHeavy_" .. client:SteamID64()
    timer.Create(id, 5, 0, function()
        if not IsValid(client) or not client:Alive() then
            timer.Remove(id)
            return
        end

        local character = client:GetCharacter()
        if not character or character:GetStatusEffect(self.uniqueID) <= 0 then
            timer.Remove(id)
            return
        end

        -- Blood decal under player
        local startPos = client:GetPos() + Vector(20, 0, 10)
        local endPos = startPos - Vector(0, 0, 500)

        local tr = util.TraceHull({
            start = startPos,
            endpos = endPos,
            mins = Vector(-4, -4, 0),
            maxs = Vector(4, 4, 1),
            filter = client,
            mask = MASK_SOLID
        })

        if tr.Hit then
            util.Decal("Blood", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal, tr.Entity)
        end

        -- Damage over time
        local hp = client:Health()
        if hp > 5 then
            client:SetHealth(hp - 5)
            net.Start("ixInjuryFlashSevere")
            net.Send(client)
        else
            client:Kill()
            character:SetStatusEffect(self.uniqueID, 0)
            timer.Remove(id)
        end

        -- Reduce duration
        character:AddStatusEffect(self.uniqueID, -0.3)
    end)
end

function STATUS:OnRemove(client)
    client:Notify("Your bleeding has stopped.")
    timer.Remove("ixBleedingHeavy_" .. client:SteamID64())
end

-- Networking for screen flash
if SERVER then
    util.AddNetworkString("ixInjuryFlashSevere")
end

if CLIENT then
    net.Receive("ixInjuryFlashSevere", function()
        local flash = vgui.Create("DPanel")
        flash:SetSize(ScrW(), ScrH())
        flash:SetBackgroundColor(Color(0, 0, 0))
        flash:SetAlpha(0)
        flash:AlphaTo(230, 0.1, 0, function()
            flash:AlphaTo(0, 2, 0.2, function() flash:Remove() end)
        end)
    end)
end

PLUGIN:RegisterStatusEffect(STATUS)

