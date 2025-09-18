local PLUGIN = PLUGIN
local STATUS = {}

STATUS.name = "Intoxication (Synth Oil)"
STATUS.uniqueID = "itx_synthoil"

function STATUS:OnApply(client, scaleFactor)
	net.Start("ix_StartSynthOilEffects")
	
	client:SetDSP(32, false)
	timer.Simple(4, function() client:SetDSP(1, false) return end)
	net.Send(client)
end

function STATUS:OnRemove(client)
	client:SetDSP(1, false)
	
	net.Start("ix_EndSynthOilEffects")
	net.Send(client)
end

function STATUS:OnThink(client, scaleFactor)
	if client:Alive() then
		local character = client:GetCharacter()
		if not character then return end
		
		character:AddStatusEffect(self.uniqueID, -1)
	end
end

if CLIENT then
	cSoundPatchAmbient = nil
	
	local function InitAmbientSound()
		cSoundPatchAmbient = CreateSound(LocalPlayer(), "ambient/levels/citadel/citadel_ambient_scream_loop1.wav") 
	end

	net.Receive("ix_StartSynthOilEffects", function()

		local client = LocalPlayer()
		local character = client:GetCharacter()

		if client then
		
			local uniqueID = "itx_synthoil"
			local scaleFactor = character:GetStatusEffect(uniqueID) / 100
			
			if not cSoundPatchAmbient then InitAmbientSound() end
			
			cSoundPatchAmbient:Play()
		
			-- Function to draw screen effects attenuated by scale factor
			local function DrawSynthOilEffects()
				local client = LocalPlayer()
				local character = client:GetCharacter()
				
				
				
				if client and character then
					local soundPitchFactor = (scaleFactor > 0 and scaleFactor <= 0.2) and math.floor((scaleFactor / 0.2) * 50) or (scaleFactor > 0.2 and scaleFactor <= 1) and 50 or 50
					local soundVolumeFactor = scaleFactor * 60
					local textureFactor = scaleFactor * 0.15
					local blurAlphaFactor = (scaleFactor > 0 and scaleFactor <= 0.6) and (0.16 - (scaleFactor / 0.6) * 0.14) or (scaleFactor > 0.6 and scaleFactor <= 1) and 0.02 or 0.02

					
					cSoundPatchAmbient:ChangePitch(soundPitchFactor)
					cSoundPatchAmbient:ChangeVolume(soundVolumeFactor)
					
					DrawMotionBlur(blurAlphaFactor, 0.99, 0.00)

					if textureFactor then
						DrawMaterialOverlay("effects/water_warp01", textureFactor)
					end
				end
			end					
			
			hook.Add("RenderScreenspaceEffects", "DrawSynthOilEffects", DrawSynthOilEffects)
			
		end
	end)

	net.Receive("ix_EndSynthOilEffects", function()
		cSoundPatchAmbient:Stop()
		
		hook.Remove("RenderScreenspaceEffects", "DrawSynthOilEffects")
		-- hook.Remove("PreDrawHalos", "DrawCombatStimHaloEffects")
	end)
end

if SERVER then
	util.AddNetworkString("ix_StartSynthOilEffects")
    util.AddNetworkString("ix_EndSynthOilEffects")
end

PLUGIN:RegisterStatusEffect(STATUS)
