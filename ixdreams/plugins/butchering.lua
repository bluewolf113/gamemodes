PLUGIN.name   = "Corpse Butchering"
PLUGIN.author = "Bilwin"

PLUGIN.list = {
    ["models/headcrabclassic.mdl"] = {
        impactEffect = "blood",
        butcheringTime = 5,
        slicingSound = {"ambient/machines/slicer2.wav", "ambient/machines/slicer3.wav"},
        items = {"headcrabgib"}
    },
    ["models/antlion.mdl"] = {
        impactEffect = "AntlionGib",
        butcheringTime = 5,
        slicingSound = {"ambient/machines/slicer2.wav", "ambient/machines/slicer3.wav"},
        items = {"antlionleg"}
    }
}

if SERVER then
    ix.log.AddType("playerButchered", function(client, corpse)
        return string.format("%s butchered %s.", client:Name(), corpse:GetModel())
    end)

    util.AddNetworkString("ixClearClientRagdolls")

    function PLUGIN:KeyPress(client, key)
        if not (client:GetCharacter() and client:Alive()) then return end
        if key ~= IN_USE then return end

        local tr = client:GetEyeTraceNoCursor()
        local target = tr.Entity
        if not (IsValid(target) and target:GetClass() == "prop_ragdoll" and self.list[target:GetModel()]) then return end

        local data = self.list[target:GetModel()]
        local allowedWeapons = data.butcheringWeapons or {"weapon_crowbar"}
        local wep = client:GetActiveWeapon()
        local canButch = hook.Run("CanButchEntity", client, target)

        if not (IsValid(wep) and table.HasValue(allowedWeapons, wep:GetClass())) then return end
        if target:GetNetVar("cutting", false) then return end
        if canButch == false then return end

        local butchAnim = data.animation or "Roofidle1"
        local slicingSound = (data.slicingSound and data.slicingSound[1]) or "ambient/machines/slicer1.wav"

        if client.ForceSequence then
            client:ForceSequence(butchAnim, nil, 0)
        end

        target:SetNetVar("cutting", true)
        target:EmitSound(slicingSound)

        local butcheringTime = data.butcheringTime or 2

        client:SetAction("Butchering...", butcheringTime)
        client:DoStaredAction(target, function()
            if not IsValid(client) then return end
            client:LeaveSequence()

            if IsValid(target) then
                target:SetNetVar("cutting", nil)
                local finishSound = (data.slicingSound and data.slicingSound[2]) or "ambient/machines/slicer4.wav"
                target:EmitSound(finishSound)

                local effect = EffectData()
                effect:SetOrigin(target:LocalToWorld(target:OBBCenter()))
                effect:SetScale(3)
                util.Effect(data.impactEffect or "BloodImpact", effect)

                for _, itemID in ipairs(data.items or {}) do
                    if not client:GetCharacter():GetInventory():Add(itemID) then
                        ix.item.Spawn(itemID, client)
                    end
                end

                ix.log.Add(client, "playerButchered", target)
                hook.Run("OnButchered", client, target)
                target:Remove()
            end
        end, butcheringTime, function()
            if IsValid(client) then
                client:SetAction()
                client:LeaveSequence()
                if IsValid(target) then
                    target:SetNetVar("cutting", false)
                end
            end
        end)
    end

    function PLUGIN:CanButchEntity(client, target)
        return true
    end
end

if CLIENT then
    net.Receive("ixClearClientRagdolls", function()
        local ragdoll = net.ReadEntity()
        if IsValid(ragdoll) and ragdoll:GetClass() == "class C_ClientRagdoll" then
            ragdoll:Remove()
        end
    end)
end
