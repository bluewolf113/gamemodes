ITEM.name = "Tin of Coffee Beans"
ITEM.description = "A tin of raw coffee beans, ready for roasting."
ITEM.model = "models/illusion/eftcontainers/coffee.mdl" -- Replace with an actual coffee bean model if available
ITEM.width = 1
ITEM.height = 2
ITEM.category = "Food"

ITEM.functions.Grind = {
    name = "Grind Coffee",
    tip = "Grind coffee beans near a coffee machine.",
    icon = "icon16/wrench.png",
    OnRun = function(item)
        local client = item.player
        local nearbyMachine = nil
        local grindSound = "buttons/button1.wav" -- Change this to a proper grinding sound!

        -- Scan for coffee machines within 50 units
        for _, ent in ipairs(ents.FindByClass("ix_liquidsource")) do
            if IsValid(ent) and ent:GetDisplayName() == "Coffee Machine" and client:GetPos():Distance(ent:GetPos()) <= 200 then
                nearbyMachine = ent
                break
            end
        end 

        if not nearbyMachine then
            client:Notify("You're not near a coffee machine!")
            return false
        end

        -- Fill the coffee machine with max volume
        nearbyMachine:SetLiquid("beer") -- Force liquid type change
        nearbyMachine:SetCurVolume(nearbyMachine:GetMaxVolume())
        client:Notify("You have successfully ground the coffee, but now it's beer!")

        -- Play grinding sound from the coffee machine
        nearbyMachine:EmitSound(grindSound, 75, 100) -- Volume: 75, Pitch: 100 (adjustable)

        return false
    end,

    OnCanRun = function(item)
        -- Grinding is always available as long as the player has the item
        return true
    end
}
