local PLUGIN = PLUGIN
local STATUS = {}

STATUS.name = "Drunkenness"
STATUS.uniqueID = "drunk"

function STATUS:OnApply(client, scale)
	net.Start("StartDrunkEffects")
	net.Send(client)
end

function STATUS:OnRemove(client)
	client:SetDSP(1, false)
	net.Start("EndDrunkEffects")
	net.Send(client)
end

function STATUS:OnThink(client, scale)
	if client:Alive() then
		local character = client:GetCharacter()
		if not character then return end
		local scaleFactor = scale / 100
		
		-- Set a digital sound processor (DSP) when scale above 80%
		
		if scaleFactor > 0.8 then
			client:SetDSP(14, false)
		else
			client:SetDSP(1, false)
		end
		
		client:ViewPunch(Angle(math.Rand(-0.5, 0.5) * scaleFactor, math.Rand(-0.5, 0.5) * scaleFactor, 0))
		character:AddStatusEffect(self.uniqueID, -0.05)
	end
end

if CLIENT then
	net.Receive("StartDrunkEffects", function()

		local client = LocalPlayer()
		
		if client then
			-- Function to draw screen effects attenuated by scale factor
			local function DrawDrunkEffects()
				local client = LocalPlayer()
				local character = client:GetCharacter()
				
				if client and character then
					local uniqueID = "drunk"
					local scaleFactor = character:GetStatusEffect(uniqueID) / 100
					
					if scaleFactor then
						DrawMotionBlur(0.2, scaleFactor, 0.01)
						DrawToyTown(scaleFactor * 10, scaleFactor * ScrH() / 2)
					end
				end
			end		
			-- Add render hook
			hook.Add("RenderScreenspaceEffects", "DrawDrunkEffects", DrawDrunkEffects)
		end
	end)

	net.Receive("EndDrunkEffects", function()
		hook.Remove("RenderScreenspaceEffects", "DrawDrunkEffects")
	end)
end

if SERVER then
	util.AddNetworkString("StartDrunkEffects")
    util.AddNetworkString("EndDrunkEffects")
end

PLUGIN:RegisterStatusEffect(STATUS)
