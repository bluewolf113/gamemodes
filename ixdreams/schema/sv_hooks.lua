
-- Here is where all of your serverside hooks should go.

-- Change death sounds of people in the police faction to the metropolice death sound.

function Schema:PlayerDeath(client, inflictor, attacker)
	local character = client:GetCharacter()

	if (character) then
		if (IsValid(client.ixRagdoll)) then
			client.ixRagdoll.ixIgnoreDelete = true
			client:SetLocalVar("blur", nil)

			if (hook.Run("ShouldRemoveRagdollOnDeath", client) != false) then
				client.ixRagdoll:Remove()
			end
		end

		client:SetNetVar("deathStartTime", CurTime())
		client:SetNetVar("deathTime", CurTime() + ix.config.Get("spawnTime", 5))

		character:SetData("health", nil)

		local deathSound = hook.Run("GetPlayerDeathSound", client)

		if (deathSound) then
			deathSound = deathSound or (deathSounds and deathSounds[math.random(1, #deathSounds)])

			if (client:IsFemale() and !deathSound:find("female")) then
				deathSound = deathSound:gsub("male", "female")
			end
			
			local recipientFilter = RecipientFilter()
			recipientFilter:AddAllPlayers()
			recipientFilter:RemovePlayer(client)

			client:EmitSound(deathSound or "", 75, 100, 1, CHAN_AUTO, 0, 0, recipientFilter)
		end

		local weapon = attacker:IsPlayer() and attacker:GetActiveWeapon()

		ix.log.Add(client, "playerDeath",
			attacker:GetName() ~= "" and attacker:GetName() or attacker:GetClass(), IsValid(weapon) and weapon:GetClass())
	end
end

function Schema:GetPlayerDeathSound(client)
	local character = client:GetCharacter()

	if (character and character:IsPolice()) then
		return "NPC_MetroPolice.Die"
	end
end


function Schema:OnCharacterCreated(client, character)
	ix.needs.OnCharacterCreated(client, character)
end

function Schema:OnCharacterDisconnect(client, character)
	ix.needs.OnCharacterDisconnect(client, character)
end

function Schema:PlayerLoadedCharacter(client, curChar, prevChar)
	ix.needs.PlayerLoadedCharacter(client, curChar, prevChar)
end

function Schema:LoadData()
	self:LoadCookingSources()
	self:LoadFluidSources()
	self:LoadHints()
	--self:LoadDeployedEntities()
end

function Schema:SaveData()
	self:SaveCookingSources()
	self:SaveFluidSources()
	self:SaveHints()
	self:SaveDeployedEntities()
end