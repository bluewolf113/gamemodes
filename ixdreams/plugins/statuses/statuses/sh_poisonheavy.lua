local PLUGIN = PLUGIN
local STATUS = {}

STATUS.name = "Poison (Heavy)"
STATUS.uniqueID = "poison_heavy"

function STATUS:OnApply(client, scaleFactor)
	net.Start("ix_DoPoisonHeavy")
	net.Send(client)
end

function STATUS:OnRemove(client)
	
end

function STATUS:OnThink(client, scaleFactor)
    if client:Alive() then
        local character = client:GetCharacter()
        if not character then return end

        local scaleFactor = scaleFactor / 100
        local currHealth = client:Health()
        local newHealth = currHealth - (10 * scaleFactor)

        if newHealth <= 0 then
            client:Kill()
			character:SetStatusEffect(self.uniqueID, 0)
        else
            client:SetHealth(math.Clamp(newHealth, 0, client:GetMaxHealth()))
        end

        character:AddStatusEffect(self.uniqueID, -5)
    end
end

if CLIENT then

	net.Receive("ix_DoPoisonHeavy", function()

		local client = LocalPlayer()
		local character = client:GetCharacter()
		
		local function GreenFlash()
			-- Create a green flash effect
			local flash = vgui.Create("DPanel")
			flash:SetSize(ScrW(), ScrH())
			flash:SetBackgroundColor(Color(0, 255, 0))
			flash:SetAlpha(20)
			flash:AlphaTo(0, 4, 0, function() flash:Remove() end)
		end

		if client then		
			GreenFlash()		
		end
	end)
end

if SERVER then
	util.AddNetworkString("ix_DoPoisonHeavy")
end

PLUGIN:RegisterStatusEffect(STATUS)
