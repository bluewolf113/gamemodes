ITEM.name = "Rubber Ducky"
ITEM.description = "Cute and small."
ITEM.model = "models/ug_imports/sims/gm_ducky.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.category = "Clutter"

ITEM.functions.Squeeze = {
    name = "Squeeze",
    tip = "Squeeze the item.",
    icon = "icon16/sound.png",
    OnRun = function(item)
        local client = item.player
        if not IsValid(client) then return false end

        local soundPath = "ambient/creatures/teddy.wav"
        local pitch = 300

        local ent = item.entity
        if IsValid(ent) then
            ent:EmitSound(soundPath, 75, pitch) -- volume = 75, pitch = 300
        else
            client:EmitSound(soundPath, 75, pitch)
        end

        return false
    end
}