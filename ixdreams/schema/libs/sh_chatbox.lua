-- see helix\gamemode\core\libs for original/complete

-- Private messages between players.
ix.chat.Register("pm", {
	format = "%s -> %s: %s",
	color = Color(125, 150, 75, 255),
	deadCanChat = true,

	OnChatAdd = function(self, speaker, text, bAnonymous, data)
		chat.AddText(self.color, "[PM] ", Color(255,255,255), string.format(self.format, speaker:GetName(), data.target:GetName(), text))

		if (LocalPlayer() != speaker) then
			surface.PlaySound("hl1/fvox/bell.wav")
		end
	end
})
