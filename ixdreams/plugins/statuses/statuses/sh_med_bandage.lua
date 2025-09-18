local PLUGIN = PLUGIN
local STATUS = {}

STATUS.name = "Healing (Bandage)"
STATUS.uniqueID = "med_bandage"

function STATUS:OnApply(client, scaleFactor)

end

function STATUS:OnRemove(client)
	
end

function STATUS:OnThink(client, scaleFactor)
	if client:Alive() then
		local character = client:GetCharacter()
		if not character then return end
		
		local scaleFactor = scaleFactor / 100

		local currHealth = client:Health()
		local newHealth = currHealth + 1
		
		client:SetHealth(math.Clamp(newHealth, 0, client:GetMaxHealth()))
		
		character:AddStatusEffect(self.uniqueID, -5)
	end
end

PLUGIN:RegisterStatusEffect(STATUS)
