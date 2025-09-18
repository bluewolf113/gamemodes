
ITEM.name = "Cyanide"
ITEM.model = Model("models/props_lab/jar01a.mdl")
ITEM.width = 1
ITEM.height = 1
ITEM.description = "Deadly."
ITEM.category = "Poison"

ITEM.functions.Combine = {
    name = "Poison Liquid",
    icon = "icon16/bomb.png",
    sound = "ambient/levels/labs/electric_explosion5.wav",
    
    OnRun = function(container, data)
        local client = container.player
        local poisonSource = ix.item.instances[data[1]]

        if container.GetLiquid and container:GetLiquid() and container:GetVolume() > 0 then
            -- Check if container is already poisoned
            if container.isPoisoned then
                client:Notify(string.format("This %s is already poisoned!", container:GetName()))
                return false
            end
            
            -- Apply poison effect
            container.isPoisoned = true
            client:ChatPrint(string.format("You have poisoned the liquid inside the %s.", container:GetName()))
            client:GetCharacter():PlaySound("ambient/levels/labs/electric_explosion5.wav")
            
            return true
        else
            client:Notify(string.format("There's no liquid in the %s to poison.", container:GetName()))
            return false
        end
    end,

    OnCanRun = function(item, data)
        local targetItem = ix.item.instances[data[1]]
        return targetItem and targetItem:GetLiquid() ~= nil and targetItem:GetVolume() > 0
    end
}