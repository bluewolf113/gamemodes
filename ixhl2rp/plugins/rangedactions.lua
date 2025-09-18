
PLUGIN.title = "Ranged Actions"
PLUGIN.author = "SleepyMode"
PLUGIN.description = "Implements multiple range performance actions such as /MeL."

function PLUGIN:InitializedConfig()
	ix.chat.Register("mel", {
		format = "***** %s %s",
		GetColor = function(self, speaker, text)
			local color = ix.chat.classes.ic:GetColor(speaker, text)

			return Color(color.r + 35, color.g + 35, color.b + 35)
		end,
		CanHear = ix.config.Get("chatRange", 280) * 4,
		prefix = {"/MeL", "/ActionLong"},
		description = "@cmdMe",
		indicator = "chatPerforming",
		deadCanChat = true
	})

	ix.chat.Register("mec", {
		format = "* %s %s",
		GetColor = function(self, speaker, text)
			local color = ix.chat.classes.ic:GetColor(speaker, text)

			return Color(color.r - 35, color.g - 35, color.b - 35)
		end,
		CanHear = ix.config.Get("chatRange", 280) * 0.25,
		prefix = {"/MeC", "/ActionClose"},
		description = "@cmdMe",
		indicator = "chatPerforming",
		deadCanChat = true
	})

	ix.chat.Register("med", {
		format = "** %s %s",
		GetColor = function(self, speaker, text)
			local color = ix.chat.classes.ic:GetColor(speaker, text)

			return Color(color.r - 35, color.g - 35, color.b - 35)
		end,
		CanHear = function(self, speaker, listener)
			local entFacing = speaker:GetEyeTraceNoCursor().Entity

			if (IsValid(entFacing) and entFacing:IsPlayer()) then
				return (entFacing == listener)
			else
				return false
			end
		end,
		prefix = {"/MeD", "/ActionDirect"},
		description = "@cmdMe",
		indicator = "chatPerforming",
		deadCanChat = true
	})

	ix.chat.Register("itl", {
		OnChatAdd = function(self, speaker, text)
			local color = ix.config.Get("chatColor")
			chat.AddText(Color(color.r + 35, color.g + 35, color.b + 35), "***** " .. text)
		end,
		CanHear = ix.config.Get("chatRange", 280) * 4,
		prefix = {"/ItL"},
		description = "@cmdIt",
		indicator = "chatPerforming",
		deadCanChat = true
	})

	ix.chat.Register("itc", {
		OnChatAdd = function(self, speaker, text)
			local color = ix.config.Get("chatColor")
			chat.AddText(Color(color.r - 35, color.g - 35, color.b - 35), "* " .. text)
		end,
		CanHear = ix.config.Get("chatRange", 280) * 0.25,
		prefix = {"/ItC"},
		description = "@cmdIt",
		indicator = "chatPerforming",
		deadCanChat = true
	})

	ix.chat.Register("itd", {
		OnChatAdd = function(self, speaker, listener)
			local color = ix.config.Get("chatColor")
			chat.AddText(Color(color.r - 35, color.g - 35, color.b - 35), "** " .. text)
		end,
		CanHear = function(self, speaker, listener)
			local entFacing = speaker:GetEyeTraceNoCursor().Entity

			if (IsValid(entFacing) and entFacing:IsPlayer()) then
				return (entFacing == listener)
			else
				return false
			end
		end,
		prefix = {"/ItD"},
		description = "@cmdIt",
		indicator = "chatPerforming",
		deadCanChat = true
	})
end

function PLUGIN:InitializedChatClasses()
	ix.chat.classes["me"].format = "*** %s %s"
	ix.chat.classes["me"].CanHear = function(self, speaker, listener)
		local range = ix.config.Get("chatRange", 280) * 2

		return (speaker:GetPos() - listener:GetPos()):LengthSqr() <= (range * range)
	end

	ix.chat.classes["it"].OnChatAdd = function(self, speaker, text)
		chat.AddText(ix.config.Get("chatColor"), "*** " .. text)
	end
	ix.chat.classes["it"].CanHear = function(self, speaker, listener)
		local range = ix.config.Get("chatRange", 280) * 2

		return (speaker:GetPos() - listener:GetPos()):LengthSqr() <= (range * range)
	end
end
