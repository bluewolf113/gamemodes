AMBIENCE.name = "Skycop"
AMBIENCE.description = "Creates a helicopter in the skybox."
AMBIENCE.map = "gm_construct"

AMBIENCE.onPlay = function()
    for k, v in player.Iterator() do
        v:ConCommand("play ambient/overhead/hel2.wav")
    end

    local heli = ents.Create("prop_dynamic")
    heli:SetModel("models/combine_helicopter.mdl")
    heli:SetPos(Vector(-2134.5405273438, -71.579666137695, 12034.153320313))
    heli:SetAngles(Angle(-1.6106799840927, -10.376834869385, 0))
    heli:Spawn()
    heli:SetModelScale(0.3)
    heli:ResetSequence("idle")

    -- make the helicopter smoothly move to the endpos
    local endpos = Vector(-735.07159423828, 3260.724609375, 12024.861328125)
    hook.Add("Think", "HeliThink", function()
        if ( heli:GetPos():Distance(endpos) > 100 ) then
            heli:SetPos(heli:GetPos() + (endpos - heli:GetPos()):GetNormal() * 7)
        end

        if ( heli:GetPos():Distance(endpos) < 100 ) then
            heli:Remove()
            hook.Remove("Think", "HeliThink")
        end
    end)
end

AMBIENCE_SKY_HELI = AMBIENCE.index

print("[AMBIENCE] "..AMBIENCE.name.." loaded.")