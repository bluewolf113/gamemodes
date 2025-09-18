
local PLUGIN = PLUGIN

PLUGIN.name = "Mortar Strikes"
PLUGIN.author = "Zombine"
PLUGIN.description = "Adds commands for mortar strikes."

if (SERVER) then
	util.AddNetworkString("ixMortarLaunch")
	util.AddNetworkString("ixMortarImpact")
else
	net.Receive("ixMortarLaunch", function(length)
		local pos = net.ReadVector()

		sound.Play("battlefront/world/orbital/launching-0" .. math.random(1, 5) .. ".wav", pos, 150)

		timer.Simple(1.8, function()
			sound.Play("battlefront/world/orbital/incoming-0" .. math.random(1, 6) .. ".wav", pos, 100)
		end)
	end)

	net.Receive("ixMortarImpact", function(length)
		local pos = net.ReadVector()
		local ang = net.ReadAngle()

		sound.Play("battlefront/world/explosions/boomcore-0" .. math.random(1, 8) .. ".wav", pos, 110)
		ParticleEffect("dusty_explosion_rockets", pos, ang, nil)
	end)
end

ix.command.Add("MortarStrike", {
	description = "Launches sustained mortar fire for a set duration at your crosshair.",
	superAdminOnly = true,
	arguments = {
		bit.bor(ix.type.number, ix.type.optional),
		bit.bor(ix.type.number, ix.type.optional),
		bit.bor(ix.type.number, ix.type.optional),
		bit.bor(ix.type.number, ix.type.optional),
		bit.bor(ix.type.number, ix.type.optional)
	},
	OnRun = function(self, client, radius, duration, density, damage, damageRadius)
		radius = radius or 600
		duration = duration or 5
		density = density or (duration * 2)
		damage = damage or 250
		damageRadius = damageRadius or 300

		local targetPos = client:GetEyeTrace().HitPos

		net.Start("ixMortarLaunch")
			net.WriteVector(targetPos)
		net.Broadcast()

		timer.Simple(2.7, function()
			for i = 1, duration, duration / density do
				local rand = VectorRand() * radius
					rand.z = 0
				local pos = targetPos + rand

				local landingTrace = util.TraceLine({
					start = pos + Vector(0, 0, 300),
					endpos = pos - Vector(0, 0, 16000)
				})

				local skyTrace = util.TraceLine({
					start = landingTrace.HitPos,
					endpos = landingTrace.HitPos + Vector(0, 0, 16000)
				})

				if (!skyTrace.HitSky) then continue end

				local ang = landingTrace.HitNormal:Angle()
				ang:RotateAroundAxis(ang:Right(), -90)

				timer.Simple(i + math.random(-1, 1), function()
					net.Start("ixMortarImpact")
						net.WriteVector(landingTrace.HitPos)
						net.WriteAngle(ang)
					net.Broadcast()

					util.Decal("Scorch", landingTrace.StartPos, landingTrace.HitPos - Vector(0, 0, 10))
					util.ScreenShake(landingTrace.HitPos, 30, 5, 1.5, 5000)
					util.BlastDamage(client, client, landingTrace.HitPos, damage, damageRadius)

					--[[local light = ents.Create("ix_lightflash")
						light:SetPos(landingTrace.HitPos)
					light:Spawn()]]
				end)
			end
		end)
	end
})

ix.command.Add("MortarBarrage", {
	description = "Launches a concentrated mortar barrage at your crosshair.",
	superAdminOnly = true,
	arguments = {
		bit.bor(ix.type.number, ix.type.optional),
		bit.bor(ix.type.number, ix.type.optional),
		bit.bor(ix.type.number, ix.type.optional)
	},
	OnRun = function(self, client, radius, damage, damageRadius)
		radius = radius or 600
		damage = damage or 250
		damageRadius = damageRadius or 300

		local targetPos = client:GetEyeTrace().HitPos

		net.Start("ixMortarLaunch")
			net.WriteVector(targetPos)
		net.Broadcast()

		timer.Simple(2.7, function()
			for i = 1, 25 do
				local rand = VectorRand() * radius
					rand.z = 0
				local pos = targetPos + rand

				local landingTrace = util.TraceLine({
					start = pos + Vector(0, 0, 300),
					endpos = pos - Vector(0, 0, 16000)
				})

				local skyTrace = util.TraceLine({
					start = landingTrace.HitPos,
					endpos = landingTrace.HitPos + Vector(0, 0, 16000)
				})

				if (!skyTrace.HitSky) then continue end

				local ang = landingTrace.HitNormal:Angle()
				ang:RotateAroundAxis(ang:Right(), -90)

				timer.Simple(i / (2 + i / 2), function()
					net.Start("ixMortarImpact")
						net.WriteVector(landingTrace.HitPos)
						net.WriteAngle(ang)
					net.Broadcast()

					util.Decal("Scorch", landingTrace.StartPos, landingTrace.HitPos - Vector(0, 0, 10))
					util.ScreenShake(landingTrace.HitPos, 30, 5, 1.5, 5000)
					util.BlastDamage(client, client, landingTrace.HitPos, damage, damageRadius)

					--[[local light = ents.Create("ix_lightflash")
						light:SetPos(landingTrace.HitPos)
					light:Spawn()]]
				end)
			end
		end)
	end
})