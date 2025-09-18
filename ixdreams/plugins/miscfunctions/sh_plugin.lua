local PLUGIN = PLUGIN
PLUGIN.name = "Misc Functions"
PLUGIN.author = ""
PLUGIN.description = "Extra Commands"
ix.util.Include("sv_plugin.lua")
ix.util.Include("cl_plugin.lua")

ix.chat.Register("think", {
    colorOne = Color(255, 255, 220, 150),
    colorTwo = Color(80, 80, 80),
    colorThree = Color(218, 166, 54),
    
    OnChatAdd = function(self, speaker, text)
        if LocalPlayer() == speaker then
            chat.AddText(self.colorTwo, "You think – " .. text)
        else
            chat.AddText(self.colorOne, "[THOUGHT] " .. speaker:GetName() .. " thinks – ", self.colorThree, text)
        end
    end,
    
    CanHear = function(self, speaker, listener, data)
        return listener:IsAdmin() or listener == speaker
    end,
    
    prefix = {"/Think", "/Thinks"},
    description = "Think something",
    deadCanChat = false
})

ix.command.Add("Pit", {
    description = "Personal /it command.",
    adminOnly = true,
    arguments = {ix.type.player, ix.type.text},
    OnRun = function(self, client, target, text)
        ix.chat.Send(client, "pit", text, false, nil, {target = target})

        /*
        if client:IsAdmin() then
            local receiver = target:GetName()
            local sender = client:GetName()
            ix.chat.Send(client, "pit", "[" .. sender .. " > " .. re-ceiver .. "] " .. text, false, client)
        else
            ix.chat.Send(client, "pit", text, false, target)
        end
        */
    end
})

ix.command.Add("PitB", {
    description = "Personal /it command with black text.",
    adminOnly = true,
    arguments = {ix.type.player, ix.type.text},
    OnRun = function(self, client, target, text)
        ix.chat.Send(client, "pitb", text, false, nil, {target = target})
    end
})

ix.chat.Register("pit", {
	colorOne = Color(80, 80, 80),
	colorTwo = Color(236, 180, 58),

    CanHear = function(self, speaker, listener, data) 
        return listener:IsAdmin() or listener:GetName() == data.target:GetName()
    end,
	OnChatAdd = function(self, speaker, text, bAnonymous, data)
		if LocalPlayer():IsAdmin() then
            chat.AddText(self.colorOne, "[" .. speaker:GetName() .. " -> " .. data.target:GetName() .. "] ", self.colorTwo, text)
        else
            chat.AddText(self.colorTwo, text)
        end
	end,
	filter = "actions",
	deadCanChat = true
})

ix.chat.Register("pitb", {
	colorOne = Color(80, 80, 80),
	colorTwo = Color(236, 180, 58),

    CanHear = function(self, speaker, listener, data) 
        return listener:IsAdmin() or listener:GetName() == data.target:GetName()
    end,
	OnChatAdd = function(self, speaker, text, bAnonymous, data)
		if LocalPlayer():IsAdmin() then
			chat.AddText(self.colorTwo, "[" .. speaker:GetName() .. " -> " .. data.target:GetName() .. "] ", self.colorOne, text)
		else
			chat.AddText(self.colorOne, text)
		end
	end,
	filter = "actions",
	deadCanChat = true
})





ix.command.Add("Return", {
    description = "Teleports you back to the spot where you died.",
    OnRun = function(self, client)
        if IsValid(client) then
            if client:Alive() then
                local char = client:GetCharacter()
                local oldPos = char:GetData("deathPos")

                if oldPos then
                    client:SetPos(oldPos)
                    char:SetData("deathPos", nil)
                else
                    client:Notify("No death position saved.")
                end
            else
                client:Notify("Wait until you respawn.")
            end
        end
    end
})

ix.command.Add("ClearVFire", {
    adminOnly = true,
    OnRun = function(self, client)
        for k, fire in ipairs(ents.FindByClass("vfire")) do
            fire:Remove()
        end
    end
})

ix.command.Add("ForceSay", {
    adminOnly = true,
    arguments = {ix.type.player, ix.type.text},
    OnRun = function(self, client, target, text)
        if IsValid(target) then
            target:Say(text)
        end
    end
})

ix.command.Add("SkitzoSay", {
    description = "Force a player to say something out loud without them seeing it.",
    adminOnly = true,
    arguments = {ix.type.player, ix.type.text},
    OnRun = function(self, client, target, text)
        local range = ix.config.Get("chatRange", 280) ^ 2

        if IsValid(target) then
            for k, v in ipairs(player.GetAll()) do
                if (target:GetPos() - v:GetPos()):LengthSqr() <= range then
                    if v == target then continue end

                    -- if (SERVER) then
                    ix.chat.Send(target, "ic", text, false, {v})
                    -- end
                end
            end
        end
    end
})

ix.command.Add("SkitzoMe", {
    description = "Force a player to do an action without them seeing it.",
    adminOnly = true,
    arguments = {ix.type.player, ix.type.text},
    OnRun = function(self, client, target, text)
        local range = ix.config.Get("chatRange", 280) ^ 2

        if IsValid(target) then
            for k, v in ipairs(player.GetAll()) do
                if (target:GetPos() - v:GetPos()):LengthSqr() <= range then
                    if v == target then continue end

                    -- if (SERVER) then
                    ix.chat.Send(target, "me", text, false, {v})
                    -- end
                end
            end
        end
    end
})

ix.command.Add("ForceFallOver", {
    description = "Force a player to fall over.",
    adminOnly = true,
    arguments = {ix.type.player, bit.bor(ix.type.number, ix.type.optional)},
    OnRun = function(self, client, target, time)
        if time and time > 0 then
            time = math.Clamp(time, 1, 3600)
        else
            time = 5
        end

        if not IsValid(target.ixRagdoll) then
            target:SetRagdolled(true, time)
        end
    end
})

ix.command.Add("ForceGetUp", {
    description = "Force a player to get up",
    adminOnly = true,
    arguments = {ix.type.player},
    OnRun = function(self, client, target)
        target:SetAction()
        target:SetRagdolled(false)
    end
})

ix.command.Add("CharSetTitle", {
    description = "Assign a title to a player.",
    alias = "SetTitle",
    adminOnly = true,
    arguments = {ix.type.player, ix.type.text},
    OnRun = function(self, client, target, titleName)
        if IsValid(target) then
            target:SetNetVar("Title", titleName)
            client:Notify("Assigned title '" .. titleName .. "' to " .. target:Name() .. ".")
        else
            client:Notify("Invalid target!")
        end
    end
})

ix.command.Add("CharRemoveTitle", {
    description = "Remove a title from a player.",
    alias = "RemoveTitle",
    adminOnly = true,
    arguments = {ix.type.player, ix.type.text},
    OnRun = function(self, client, target, titleName)
        if IsValid(target) then
            target:SetNetVar("Title", nil)
            client:Notify("Removed title from " .. target:Name() .. ".")
        else
            client:Notify("Invalid target!")
        end
    end
})

ix.command.Add("GmanText", {
    description = "Print text to the player's screen in the style of env_message",
    adminOnly = true,
    arguments = {ix.type.player, ix.type.text},
    OnRun = function(self, client, target, text)
		local playerTbl = target and (IsValid(target) and {target}) or not target and player.GetAll()
		
        if not playerTbl then return end
		
		net.Start("ShowEnvEventMessage")
		net.WriteString(text)
		net.Send(playerTbl)
    end
})
