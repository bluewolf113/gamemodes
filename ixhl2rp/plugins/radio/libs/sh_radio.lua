
ix.radio = ix.radio or {}
ix.radio.channels = ix.radio.channels or {}

ix.radio.types			= {}
ix.radio.types.whisper	= 1
ix.radio.types.talk		= 2
ix.radio.types.yell		= 3

function ix.radio.IsValidChannel(channel)
	return istable(ix.radio.channels[channel])
end

function ix.radio.IsFrequencyChannel(channel)
	return ix.radio.channels[channel].isFrequency
end

function ix.radio.RegisterChannel(uniqueID, data)
	if (!istable(data)) then
		ErrorNoHalt("[IX: Radio] Attempted to register channel \"" .. uniqueID .. "\" with invalid data.")
		return
	end

	if (!data.color) then
		data.color = Color(42, 179, 0, 255)
	end

	ix.radio.channels[uniqueID] = data
end

function ix.radio.RemoveChannel(uniqueID)
	ix.radio.channels[uniqueID] = nil
end

function ix.radio.FindByID(channelID)
	return ix.radio.channels[channelID]
end

function ix.radio.AddPlayerToChannel(client, channel)
	if (ix.radio.IsValidChannel(channel)) then
		local character = client:GetCharacter()

		local radioChannels = character:GetData("radioChannels", {})
			radioChannels[channel] = true
		character:SetData("radioChannels", radioChannels)
	end
end

function ix.radio.RemovePlayerFromChannel(client, channel)
	if (ix.radio.IsValidChannel(channel)) then
		local character = client:GetCharacter()

		local radioChannels = character:GetData("radioChannels", {})
			radioChannels[channel] = false
		character:SetData("radioChannels", radioChannels)
	end
end

function ix.radio.IsPlayerSubscribedToChannel(client, channel)
	-- The player cannot be subscribed to an invalid channel.
	if (!ix.radio.IsValidChannel(channel)) then
		return false
	end

	local character = client:GetCharacter()
	local radioChannels = character:GetData("radioChannels", {})

	-- If they are manually subscribed to the channel, they have access.
	if (radioChannels[channel]) then
		return true
	end

	-- If they have an handheld radio of that frequency in their inventory, they have access.
	if (character:GetInventory():HasItemOfBase("base_handheld_radio", {["channel"] = channel})) then
		return true
	end

	-- Check if the faction has access.
	local faction = ix.faction.indices[character:GetFaction()]

	if (faction and istable(faction.radioChannels) and faction.radioChannels[channel]) then
		return true
	end

	-- If it is overriden somewhere, grant the player access.
	return (hook.Run("IsPlayerSubscribedToChannel", client, channel) == true)
end

function ix.radio.CanPlayerSay(client, text)
	-- Require a valid client for this.
	if (!IsValid(client)) then
		return false
	end

	-- The client must be alive to use this chat.
	-- The client must be unrestrained to use this chat.
	if (!client:Alive() or client:IsRestricted()) then
		client:NotifyLocalized("notNow")
		return false 
	end

	local bValidChannel = true
	local radioChannel = client:GetCharacter():GetRadioChannel()

	-- Here, we don't want to return false immediately.
	-- This is because when it comes to stationary radios, there is
	-- a very big chance the player will not have a radio channel set
	-- and he will most definitely not have a radio channel set at the
	-- same frequency as the radio in question.
	if (radioChannel != nil and ix.radio.IsValidChannel(radioChannel) and !ix.radio.IsFrequencyChannel(radioChannel)) then
		bValidChannel = true
	end

	-- If the player isn't subscribed to the channel, look for a stationary
	-- radio around the player.
	if (!bValidChannel or !ix.radio.IsPlayerSubscribedToChannel(client, radioChannel)) then
		local radioItems = ents.FindInSphere(client:GetPos(), ix.config.Get("chatRange", 280))

		local bFound = false
		for k, v in pairs(radioItems) do
			if (v:GetClass() == "ix_stationary_radio") then
				client.ixStationaryChannel = v:GetRadioChannel()
				bValidChannel = true
				bFound = true
				break
			end
		end

		if (!bValidChannel) then
			client:Notify("You must speak on a valid radio channel!")
			return false
		end

		if (!bFound) then
			client:Notify("You do not have any radio devices available!")
			return false
		end
	end

	return (hook.Run("CanPlayerSayRadio", client, text) != false)
end

function ix.radio.CanPlayerHear(speaker, listener)
	local speakerChannel = speaker:GetCharacter():GetRadioChannel()

	if (ix.radio.IsPlayerSubscribedToChannel(listener, speakerChannel)) then
		return true
	end

	return (hook.Run("CanPlayerHearRadio", speaker, listener) == true)
end

function ix.radio.RadioSay(client, text, radioType)
	radioType = radioType or ix.radio.types.talk

	local rtext = "radios"

	if (radioType == ix.radio.types.whisper) then
		rtext = "whispers"
	elseif (radioType == ix.radio.types.yell) then
		rtext = "yells"
	end

	local name = client:GetCharacter():GetRadioChannel()
	local channel = ix.radio.FindByID(name)

	if (name:find("freq_")) then
		name = string.sub(name, 6)
	end

	chat.AddText(channel and channel.color or Color(42, 179, 0, 255), client:Name() .. " " .. rtext .. " on " .. name .. " \"" .. text .. "\"")
end

function ix.radio.CanPlayerHearEavesdrop(client, listener, radioType)
	-- We don't want players to see both the normal radio
	-- message and the eavesdrop message.
	if (ix.radio.CanPlayerHear(client, listener)) then
		return false 
	end

	local range = ix.config.Get("chatRange", 280)

	if (radioType == ix.radio.types.whisper) then
		range = range * 0.25
	elseif (radioType == ix.radio.types.yell) then
		range = range * 2
	end

	return (client:GetPos() - listener:GetPos()):LengthSqr() <= (range * range)
end

function ix.radio.EavesdropSay(client, text, radioType)
	local rtext = "radios"

	if (radioType == ix.radio.types.whisper) then
		rtext = "whispers"
	elseif (radioType == ix.radio.types.yell) then
		rtext = "yells"
	end

	local genderText = "his"

	if (client:IsFemale()) then
		genderText = "her"
	end

	chat.AddText(ix.chat.classes.ic:GetColor(client, text), client:Name(), " ", rtext, " on ", genderText, " radio \"", text, "\"")
end