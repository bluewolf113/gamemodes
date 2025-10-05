local PLUGIN = PLUGIN
local STATUS = {}

STATUS.name = "Nausea"
STATUS.uniqueID = "nausea"

-- No condition: must be applied manually
STATUS.condition = function(ply, dmgInfo, hitgroup, dt)
    return false
end

function STATUS:OnApply(client, scaleFactor)
    client:ChatPrint("You feel nauseous...")

    if CLIENT and client == LocalPlayer() then
        -- Green tint overlay
        hook.Add("RenderScreenspaceEffects", "ixNauseaTint", function()
            local tab = {}
            tab["$pp_colour_addr"]       = 0
            tab["$pp_colour_addg"]       = 0.05
            tab["$pp_colour_addb"]       = 0
            tab["$pp_colour_brightness"] = 0
            tab["$pp_colour_contrast"]   = 1
            tab["$pp_colour_colour"]     = 0.9
            DrawColorModify(tab)
        end)
    end

    -- Random wretch/vomit timer
    local id = "ixNausea_" .. client:SteamID64()
    timer.Create(id, math.random(10, 20), 0, function()
        if not IsValid(client) then
            timer.Remove(id)
            return
        end

        local character = client:GetCharacter()
        if not character or character:GetStatusEffect(self.uniqueID) <= 0 then
            timer.Remove(id)
            return
        end

        if math.random(3) == 1 then
            client:EmitSound("npc/barnacle/barnacle_digesting1.wav", 70, 100)
            ix.chat.Send(client, "notice", client:Name() .. " looks like they might vomit.")

            -- Vomit decal
            local tr = util.TraceLine({
                start = client:EyePos(),
                endpos = client:EyePos() + client:GetForward() * 50,
                filter = client
            })
            if tr.Hit then
                util.Decal("BeerSplash", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
            end
        end
    end)
end

function STATUS:OnRemove(client)
    client:ChatPrint("Your nausea subsides.")

    if CLIENT and client == LocalPlayer() then
        hook.Remove("RenderScreenspaceEffects", "ixNauseaTint")
    end

    timer.Remove("ixNausea_" .. client:SteamID64())
end

-- Tooltip integration
function PLUGIN:PopulateCharacterInfo(client, character, tooltip)
    local statuses = character:GetAllStatusEffects and character:GetAllStatusEffects() or {}
    if statuses["nausea"] and statuses["nausea"] > 0 then
        local panel = tooltip:AddRowAfter("desc", "charstatus_nausea")
        panel:SetBackgroundColor(Color(0, 150, 0)) -- green tint
        panel:SetText("They look nauseous")
        panel:SizeToContents()
    end
end

PLUGIN:RegisterStatusEffect(STATUS)
