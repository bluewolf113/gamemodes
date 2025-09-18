local PLUGIN = PLUGIN
local STATUS = {}

STATUS.name = "Intoxication (Combat Stim)"
STATUS.uniqueID = "itx_combatstim"

function STATUS:OnApply(client, scaleFactor)
	net.Start("ix_StartCombatStimEffects")
	
	local currMaxHealth = client:GetMaxHealth() + 50
	local currHealth = client:Health() + 50
	
	client:SetMaxHealth(currMaxHealth)
	client:SetHealth(currHealth)
	
	client:ViewPunch(Angle(math.Rand(-3, 3), math.Rand(-3, 3), 0))
	
	client:SetDSP(32, false)
	timer.Simple(4, function() client:SetDSP(1, false) return end)
	net.Send(client)
end

function STATUS:OnRemove(client)
	local currMaxHealth = client:GetMaxHealth() - 50
	local currHealth = client:Health() - 50
	client:SetDSP(1, false)
	client:SetMaxHealth(currMaxHealth)
	client:SetHealth(currHealth)
	
	client:SetWalkSpeed(ix.config.Get("walkSpeed", 160))
	client:SetRunSpeed(ix.config.Get("runSpeed", 240))
	
	net.Start("ix_EndCombatStimEffects")
	net.Send(client)
end

function STATUS:OnThink(client, scaleFactor)
	if client:Alive() then
		local character = client:GetCharacter()
		if not character then return end
		
		local scaleFactor = scaleFactor / 100
		
		local currWalkSpeed = ix.config.Get("walkSpeed", 160) * (1 + (0.25 * scaleFactor))
		local currRunSpeed = ix.config.Get("runSpeed", 240) * (1 + (0.75 * scaleFactor))
				
		client:SetWalkSpeed(currWalkSpeed)
		client:SetRunSpeed(currRunSpeed)

		character:AddStatusEffect(self.uniqueID, -0.556)
	end
end

if CLIENT then
	net.Receive("ix_StartCombatStimEffects", function()

		local client = LocalPlayer()
		local character = client:GetCharacter()

		if client then
		
			local uniqueID = "itx_combatstim"
			local scaleFactor = character:GetStatusEffect(uniqueID) / 100
		
			-- Function to draw screen effects attenuated by scale factor
			local function DrawCombatStimEffects()
				local client = LocalPlayer()
				local character = client:GetCharacter()
				
				if client and character then
					local sharpenFactor = scaleFactor

					if sharpenFactor then
						DrawSharpen(sharpenFactor * 4, 1)
					end
				end
			end		
			
			-- local entsTbl = {}
			-- for _, ent in (ents.Iterator() or {}) do
				-- if ent:IsPlayer() or ent:IsNPC() then
					-- table.insert(entsTbl, ent)
				-- end
			-- end		
			
			-- local color_white = Color(255, 255, 255)
				
			-- local function DrawCombatStimHaloEffects()

				-- local client = LocalPlayer()
				-- local character = client:GetCharacter()	
				-- local scaleFactor = (character:GetStatusEffect(uniqueID) or 0) / 100
				
				-- local blurFactor = scaleFactor * 4
				-- local passFactor = scaleFactor * 2
				
				-- halo.Add(entsTbl, color_white, blurFactor, blurFactor, passFactor)
			-- end			
			
			hook.Add("RenderScreenspaceEffects", "DrawCombatStimEffects", DrawCombatStimEffects)
			-- hook.Add("PreDrawHalos", "DrawCombatStimHaloEffects", DrawCombatStimHaloEffects)
			
		end
	end)

	net.Receive("ix_EndCombatStimEffects", function()
		hook.Remove("RenderScreenspaceEffects", "DrawCombatStimEffects")
		-- hook.Remove("PreDrawHalos", "DrawCombatStimHaloEffects")
	end)
end

if SERVER then
	util.AddNetworkString("ix_StartCombatStimEffects")
    util.AddNetworkString("ix_EndCombatStimEffects")
end

PLUGIN:RegisterStatusEffect(STATUS)
