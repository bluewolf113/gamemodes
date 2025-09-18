LIQUID.name = "Gasoline"
LIQUID.color = Color(255, 69, 0, 255) -- Orangish-red hue to indicate danger
LIQUID.potency = 10
LIQUID.quench = -3

function LIQUID:OnConsume(client, volume)
    if not IsValid(client) then return end

    local char = client:GetCharacter()
    if not char then return end -- Ensure character is valid

    -- Get quench and potency factors, defaulting to 1 if not set
    local quenchMultiplier = self.quench or 1
    local potencyMultiplier = self.potency or 0 -- Default to 0 if no poisoning effect

    -- Calculate thirst recovery
    local thirstRestored = volume * 0.1 * quenchMultiplier
    char:AddNeed("thirst", thirstRestored)

    -- Calculate poisoning effect (scaled by potency)
    local poisonDamage = volume * 0.5 * potencyMultiplier
    local duration = math.ceil(poisonDamage / 2) -- Poison lasts proportionally longer
    local interval = 1 -- Damage every second

    if potencyMultiplier > 0 then
        client:Notify("You feel a burning sensation spreading through your body...")

        -- Apply poison over time
        timer.Create("PoisonEffect_" .. client:SteamID(), interval, duration, function()
            if not IsValid(client) or not client:Alive() then
                timer.Remove("PoisonEffect_" .. client:SteamID()) -- Stop poison if player is dead
                return
            end

            -- Reduce health
            client:SetHealth(math.max(client:Health() - 2, 0))

            -- Death check
            if client:Health() <= 0 then
                client:Kill() -- Instantly kills the player
            else
                client:EmitSound("ambient/water/drip2.wav", 50, 100) -- Weak, unsettling sound
            end
        end)
    end
end