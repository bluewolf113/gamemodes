
local PLUGIN = PLUGIN

local channels_text = ""
local current_channel = ""
local chatboxPlugin = nil

function PLUGIN:HUDPaint(width, height, alpha)
	local localPlayer = LocalPlayer()
	local character = nil

	if (IsValid(localPlayer)) then
		character = localPlayer:GetCharacter()
	end

	if (character and IsValid(ix.gui.chat) and ix.gui.chat:IsVisible() and ix.gui.chat.bActive) then
		local radioChannels = {}

		for k, v in pairs(ix.radio.channels) do
			if (ix.radio.IsPlayerSubscribedToChannel(localPlayer, k)) then
				radioChannels[#radioChannels + 1] = k
			end
		end

		channels_text = "Radio Channels: " .. ((#radioChannels > 0) and table.concat(radioChannels, ", ") or "none")
		current_channel = "Current Channel: " .. (character:GetRadioChannel() or "none")

		local x, y = ix.gui.chat:GetPos()

		y = y - 20
		draw.SimpleTextOutlined(current_channel, "DebugFixed", x, y, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color(0, 0, 0))

		y = y - 20
		draw.SimpleTextOutlined(channels_text, "DebugFixed", x, y, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color(0, 0, 0))
	end
end