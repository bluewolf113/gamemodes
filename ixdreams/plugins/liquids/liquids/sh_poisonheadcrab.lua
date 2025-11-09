
LIQUID.name = "Headcrab Venom"
LIQUID.color = Color(218, 165, 32, 255) -- Golden amber tone
LIQUID.potency = 70
LIQUID.quench = 0.45

function LIQUID:OnConsume(client, volume)
    if not IsValid(client) then return end

    local char = client:GetCharacter()
    if not char then return end -- Ensure character is valid

    -- Get quench and potency factors, defaulting to 1 if not set
    local quenchMultiplier = self.quench or 1
    local potencyMultiplier = self.potency or 0 -- Default to 0 if no drunkenness effect

    -- Calculate thirst recovery
    local thirstRestored = volume * 0.1 * quenchMultiplier
    char:AddNeed("thirst", thirstRestored)

    -- Calculate drunkenness effect
    local added = volume * 0.04 * potencyMultiplier
    char:AddStatusEffect("poisonlight", added)

    -- Optional feedback
    --client:ChatPrint("Your thirst has been reduced by " .. math.floor(thirstRestored) .. ".")
    --if potencyMultiplier > 0 then
        --client:ChatPrint("You feel the effects of alcohol increasing by " .. math.floor(drunkennessAdded) .. "%.")
    --end
end

