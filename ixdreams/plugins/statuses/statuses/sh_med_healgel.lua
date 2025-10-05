local PLUGIN = PLUGIN
local STATUS = {}

STATUS.name = "Healing (Medical Gel)"
STATUS.uniqueID = "med_healgel"

function STATUS:OnApply(client, scaleFactor)
	net.Start("ix_DoMedGelEffects")
	net.Send(client)
	ply:SetNetVar("bleeding", nil)
end

function STATUS:OnRemove(client)
	
end

function STATUS:OnThink(client, scaleFactor)
	if client:Alive() then
		local character = client:GetCharacter()
		if not character then return end
		
		local scaleFactor = scaleFactor / 100

		local currHealth = client:Health()
		local newHealth = currHealth + (10 * scaleFactor)
		
		client:SetHealth(math.Clamp(newHealth, 0, client:GetMaxHealth()))
		
		character:AddStatusEffect(self.uniqueID, -20)
	end
end

if CLIENT then

	net.Receive("ix_DoMedGelEffects", function()

		local client = LocalPlayer()
		local character = client:GetCharacter()
		
		local function GreenFlash()
			-- Create a green flash effect
			local flash = vgui.Create("DPanel")
			flash:SetSize(ScrW(), ScrH())
			flash:SetBackgroundColor(Color(0, 255, 0))
			flash:SetAlpha(100)
			flash:AlphaTo(0, 4, 0, function() flash:Remove() end)
		end

		if client then		
			GreenFlash()		
		end
	end)
end

if SERVER then
	util.AddNetworkString("ix_DoMedGelEffects")
end

PLUGIN:RegisterStatusEffect(STATUS)
