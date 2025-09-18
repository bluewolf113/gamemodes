local PLUGIN = PLUGIN

function PLUGIN:CalcMainActivity(ply, vel)
    if not IsValid(ply) or ply:IsWepRaised() then return end
    if not ply:IsOnGround() then return end

    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) or not self.moodAffectedWeapons[wep:GetClass()] then return end

    local char = ply:GetCharacter()
    if not char then return end

    local class   = ix.anim.GetModelClass(ply:GetModel())
    local moodSet = self.moods[class]
    if not moodSet then return end

    local act = ply.CalcIdeal
    local list, idx

    if act == ACT_MP_STAND_IDLE then
        list = moodSet.stand
        idx  = char:GetMoodStand()
    elseif act == ACT_MP_WALK then
        list = moodSet.walk
        idx  = char:GetMoodWalk()
    elseif act == ACT_MP_RUN then
        list = moodSet.run
        idx  = char:GetMoodRun()
    end

    local entry = list and list[idx]
    if not entry or not entry.sequence then
        if ply.AnimClearGestureSlot then
            ply:AnimClearGestureSlot(GESTURE_SLOT_CUSTOM)
        end
        return
    end

    local seqId = ply:LookupSequence(entry.sequence)
    if seqId == -1 then return end

    if ply.AnimClearGestureSlot then
        ply:AnimClearGestureSlot(GESTURE_SLOT_CUSTOM)
    end

    if entry.isGesture then
        ply:AddVCDSequenceToGestureSlot(GESTURE_SLOT_CUSTOM, seqId, 0, true)
    else
        ply.CalcSeqOverride = seqId
    end
end
