
LIQUID.name = "Source Water"
LIQUID.color = Color(4, 150, 199, 255)
LIQUID.quench = 0.95
LIQUID.taste = "It's clean, crisp water."
LIQUID.look = "a clear liquid test."

function LIQUID:OnConsume(client, volume)
    if not IsValid(client) then return end

    local char = client:GetCharacter()
    if not char then return end -- Ensure character is valid

    local quenchMultiplier = self.quench or 1 -- Default quench value is 1 if not set
    local thirstRestored = volume * 0.1 * quenchMultiplier

    -- Apply dynamic thirst recovery
    char:AddNeed("thirst", thirstRestored)

    -- Optional feedback
    client:ChatPrint("Your thirst has increased by " .. math.floor(thirstRestored) .. ".")
end

