local PLUGIN = PLUGIN
local STATUS = {}

STATUS.name = "Bleeding"
STATUS.uniqueID = "bleeding"

-- Trigger on bullet, club, or slash damage
STATUS.condition = function(ply, dmgInfo, hitgroup, dt)
    return bit.band(dt, bit.bor(DMG_BULLET, DMG_CLUB, DMG_SLASH)) ~= 0
        and math.random(3) == 1
end

function STATUS:OnApply(client, scaleFactor)
    client:ChatPrint("You feel warm blood run down you. You bleed.")

    local id = "ixBleeding_" .. client:SteamID64()
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
            client:SetHealth(hp - 2)
            net.Start("ixInjuryFlash")
            net.Send(client)
        else
            client:Kill()
            character:SetStatusEffect(self.uniqueID, 0)
            timer.Remove(id)
        end

        -- Reduce duration
        character:AddStatusEffect(self.uniqueID, -1)
    end)
end

function STATUS:OnRemove(client)
    client:ChatPrint("Your bleeding has stopped.")
    timer.Remove("ixBleeding_" .. client:SteamID64())
end

-- Networking for screen flash
if SERVER then
    util.AddNetworkString("ixInjuryFlash")
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

function PLUGIN:PopulateCharacterInfo(client, character, tooltip)
    local statuses = character:GetAllStatusEffects and character:GetAllStatusEffects() or {}
    if statuses["bleeding"] and statuses["bleeding"] > 0 then
        local panel = tooltip:AddRowAfter("desc", "charstatus_bleeding")
        panel:SetBackgroundColor(Color(150, 0, 0)) -- dark red
        panel:SetText("They are bleeding")
        panel:SizeToContents()
    end
end

PLUGIN:RegisterStatusEffect(STATUS)

