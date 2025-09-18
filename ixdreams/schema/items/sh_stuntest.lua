ITEM.name = "Ragdoll Pill"
ITEM.description = "A strange pill that makes your body go limp for a while."
ITEM.model = "models/props_lab/jar01b.mdl"
ITEM.category = "Medical"
ITEM.width = 1
ITEM.height = 1

ITEM.functions.Use = {
    name = "Swallow",
    icon = "icon16/pill.png",
    OnRun = function(item)
        local client = item.player

        if SERVER and IsValid(client) then
            client:SetRagdolled(true, 15)
        end

        return true -- item is consumed
    end
}