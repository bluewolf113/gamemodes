
local PLUGIN = PLUGIN

do
	local CLASS = {}
	CLASS.indicator = "chatRadio"

	function CLASS:CanSay(speaker, text)
		return ix.radio.CanPlayerSay(speaker, text)
	end

	function CLASS:CanHear(speaker, listener)
		return ix.radio.CanPlayerHear(speaker, listener)
	end

	function CLASS:OnChatAdd(speaker, text)
		return ix.radio.RadioSay(speaker, text, ix.radio.types.talk)
	end

	ix.chat.Register("radio", CLASS)
end

do
	local CLASS = {}
	CLASS.indicator = "chatRadio"

	function CLASS:CanSay(speaker, text)
		return ix.radio.CanPlayerSay(speaker, text)
	end

	function CLASS:CanHear(speaker, listener)
		return ix.radio.CanPlayerHear(speaker, listener)
	end

	function CLASS:OnChatAdd(speaker, text)
		return ix.radio.RadioSay(speaker, text, ix.radio.types.whisper)
	end

	ix.chat.Register("radio_whisper", CLASS)
end

do
	local CLASS = {}
	CLASS.indicator = "chatRadio"

	function CLASS:CanSay(speaker, text)
		return ix.radio.CanPlayerSay(speaker, text)
	end

	function CLASS:CanHear(speaker, listener)
		return ix.radio.CanPlayerHear(speaker, listener)
	end

	function CLASS:OnChatAdd(speaker, text)
		return ix.radio.RadioSay(speaker, text, ix.radio.types.yell)
	end

	ix.chat.Register("radio_yell", CLASS)
end

do
	local CLASS = {}

	function CLASS:CanHear(speaker, listener)
		return ix.radio.CanPlayerHearEavesdrop(speaker, listener, ix.radio.types.talk)
	end

	function CLASS:OnChatAdd(speaker, text)
		return ix.radio.EavesdropSay(speaker, text, ix.radio.types.talk)
	end

	ix.chat.Register("radio_eavesdrop", CLASS)
end

do
	local CLASS = {}

	function CLASS:CanHear(speaker, listener)
		return ix.radio.CanPlayerHearEavesdrop(speaker, listener, ix.radio.types.whisper)
	end

	function CLASS:OnChatAdd(speaker, text)
		return ix.radio.EavesdropSay(speaker, text, ix.radio.types.whisper)
	end

	ix.chat.Register("radio_eavesdrop_whisper", CLASS)
end

do
	local CLASS = {}

	function CLASS:CanHear(speaker, listener)
		return ix.radio.CanPlayerHearEavesdrop(speaker, listener, ix.radio.types.yell)
	end

	function CLASS:OnChatAdd(speaker, text)
		return ix.radio.EavesdropSay(speaker, text, ix.radio.types.yell)
	end

	ix.chat.Register("radio_eavesdrop_yell", CLASS)
end
