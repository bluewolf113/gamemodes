
local PLUGIN = PLUGIN

ix.command.Add("CharAddRadioChannel", {
	description = "Subscribes a player to a radio channel.",
	privilege = "Helix - Manage Radio",
	adminOnly = true,
	arguments = {
		ix.type.player,
		ix.type.string
	},
	OnRun = function(self, client, target, channel)
		if (ix.radio.IsValidChannel(channel)) then
			ix.radio.AddPlayerToChannel(target, channel)

			client:Notify("You have subscribed " .. target:Name() .. " to the " .. channel .. " channel.")
			target:Notify("You have been subscribed to the " .. channel .. " channel by " .. client:Name() .. ".")
		else
			return "This channel does not exist!"
		end
	end
})

ix.command.Add("CharRemoveRadioChannel", {
	description = "Unsubscribes a player to a radio channel.",
	privilege = "Helix - Manage Radio",
	adminOnly = true,
	arguments = {
		ix.type.player,
		ix.type.string
	},
	OnRun = function(self, client, target, channel)
		if (ix.radio.IsValidChannel(channel)) then
			ix.radio.RemovePlayerFromChannel(target, channel)

			client:Notify("You have unsubscribed " .. target:Name() .. " from the " .. channel .. " channel.")
			target:Notify("You have been unsubscribed from the " .. channel .. " channel by " .. client:Name() .. ".")
		else
			return "This channel does not exist!"
		end
	end
})

ix.command.Add("SetChannel", {
	alias = "SC",
	arguments = ix.type.text,

	OnRun = function(self, client, text)
		text = text:Trim()
		local freq = tonumber(text)

		if (freq) then
			local item = client:GetCharacter():GetInventory():HasItem("handheld_radio")

			if (item) then
				if (!ix.radio.IsValidChannel("freq_" .. text)) then
					ix.radio.RegisterChannel("freq_" .. text, {
						isFrequency = true
					})
				end

				item:SetData("channel", "freq_" .. text)
				client:GetCharacter():SetRadioChannel("freq_" .. text)
				client:Notify("You have set your radio channel to " .. freq)

				net.Start("ixRadio.registerChannel")
					net.WriteString("freq_" .. text)
				net.Broadcast()
			else
				client:Notify("You do not have an handheld radio to use this frequency on!")
			end
		else
			local name = string.gsub(text, "%s", "_")

			if (ix.radio.IsValidChannel(name)) then
				if (ix.radio.IsPlayerSubscribedToChannel(client, name)) then
					client:GetCharacter():SetRadioChannel(name)
					client:Notify("You have set your channel to \""..name.."\"")
				else
					client:Notify("You do not have access to this channel!")
				end
			else
				client:Notify("This channel doesn't exist!")
			end
		end
	end,
})

ix.command.Add("Radio", {
	alias = "R",
	arguments = ix.type.text,

	OnRun = function(self, client, text)
		if (!ix.radio.CanPlayerSay(client, text)) then
			return
		end

		ix.chat.Send(client, "radio", text)
		ix.chat.Send(client, "radio_eavesdrop", text)
	end,
})

ix.command.Add("RadioWhisper", {
	alias = "RW",
	arguments = ix.type.text,

	OnRun = function(self, client, text)
		if (!ix.radio.CanPlayerSay(client, text)) then
			return
		end

		ix.chat.Send(client, "radio_whisper", text)
		ix.chat.Send(client, "radio_eavesdrop_whisper", text)
	end,
})

ix.command.Add("RadioYell", {
	alias = "RY",
	arguments = ix.type.text,

	OnRun = function(self, client, text)
		if (!ix.radio.CanPlayerSay(client, text)) then
			return
		end

		ix.chat.Send(client, "radio_yell", text)
		ix.chat.Send(client, "radio_eavesdrop_yell", text)
	end,
})
