PLUGIN.name = "Sing Command"
PLUGIN.author = "P!"
PLUGIN.description = "Adds a /sing command with a special chat class."

ix.chat.Register("sing", {
    format = "%s sings: %s",
    GetColor = function(self, speaker, text)
        return Color(73, 158, 186) -- Light blue color
    end,
    CanHear = function(self, speaker, listener)
        local chatRange = ix.config.Get("chatRange", 280)
        return speaker:GetPos():DistToSqr(listener:GetPos()) < (chatRange * 2) ^ 2
    end,
    OnChatAdd = function(self, speaker, text)
        chat.AddText(Material("cellar/chat/whisper.png"), " ", self:GetColor(speaker, text), speaker:Name(), " sings: ", text)
    end,
    prefix = {"/sing"},
    filter = "ic"
})
