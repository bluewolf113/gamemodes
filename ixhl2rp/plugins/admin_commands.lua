PLUGIN.name = "Admin Commands"
PLUGIN.author = "ZeMysticalTaco"
PLUGIN.description = "Administration Suite for Helix"

ix.command.Add("PlyKick", {
	syntax = "<string Player> <string Reason>",
	adminOnly = true,
	description = "Kick a player from the server.",
	arguments = {ix.type.character, bit.bor(ix.type.string, ix.type.optional)},
	OnRun = function(self, client, target, reason)
		if SERVER then
			if target then
				serverguard.command.Run(client, "kick", false, target.player:Name(), reason)
			end
		end
	end
})

ix.command.Add("PlyBan", {
	syntax = "<string Player> <string Reason>",
	adminOnly = true,
	description = "Ban a player from the server.",
	arguments = {ix.type.character, ix.type.number, bit.bor(ix.type.string, ix.type.optional)},
	OnRun = function(self, client, target, length, reason)
		if SERVER then
			if target then
				serverguard.command.Run(client, "ban", false, target.player:Name(), length, reason)
			end
		end
	end
})

ix.command.Add("PlyTeleport", {
	syntax = "<string Player>",
	adminOnly = true,
	description = "Bring a player to your target location.",
	arguments = {ix.type.character, bit.bor(ix.type.bool, ix.type.optional)},
	OnRun = function(self, client, target, silent)
		if SERVER then
			if target then
				serverguard.command.Run(client, "send", silent or false, target.player:Name())
			end
		end
	end
})

ix.command.Add("PlyBring", {
	syntax = "<string Player>",
	adminOnly = true,
	description = "Bring a player to you.",
	arguments = {ix.type.character},
	OnRun = function(self, client, target)
		if SERVER then
			if target then
				serverguard.command.Run(client, "send", true, target.player:Name(), client:Name())

				ix.util.Notify(client:Name() .. " has brought " .. target.player:Name() .. " to them.")
			end
		end
	end
})

ix.command.Add("PlyBringS", {
	syntax = "<string Player>",
	adminOnly = true,
	description = "Bring a player to you silently.",
	arguments = {ix.type.character},
	OnRun = function(self, client, target)
		if SERVER then
			if target then
				serverguard.command.Run(client, "send", true, target.player:Name(), client:Name())

				--ix.util.Notify(client:Name() .. " has brought " .. target.player:Name() .. " to them.")
			end
		end
	end
})

ix.command.Add("PlySend", {
	syntax = "<string Player>",
	adminOnly = true,
	description = "Send a player to another player.",
	arguments = {ix.type.character, ix.type.character, bit.bor(ix.type.bool, ix.type.optional)},
	OnRun = function(self, client, target, destination, silent)
		if SERVER then
			if target then
				serverguard.command.Run(client, "send", silent or false, target.player:Name(), destination.player:Name())
			end
		end
	end
})

ix.command.Add("PlyGoto", {
	syntax = "<string Player>",
	adminOnly = true,
	description = "Send a player to another player.",
	arguments = {ix.type.character, bit.bor(ix.type.bool, ix.type.optional)},
	OnRun = function(self, client, target, silent)
		if SERVER then
			if target then
				serverguard.command.Run(client, "tp", silent or false, target.player:Name())
			end
		end
	end
})


ix.command.Add("PlySetHP", {
	syntax = "<string Player>",
	adminOnly = true,
	description = "Set a player's HP.",
	arguments = {ix.type.character, ix.type.number, bit.bor(ix.type.bool, ix.type.optional)},
	OnRun = function(self, client, target, hp, silent)
		if SERVER then
			if target then
				serverguard.command.Run(client, "hp", silent or false, target.player:Name(), hp)
			end
		end
	end
})

ix.command.Add("PlySetArmor", {
	syntax = "<string Player>",
	adminOnly = true,
	description = "Set a player's armor.",
	arguments = {ix.type.character, ix.type.number, bit.bor(ix.type.bool, ix.type.optional)},
	OnRun = function(self, client, target, armor, silent)
		if SERVER then
			if target then
				serverguard.command.Run(client, "armor", silent or false, target.player:Name(), armor)
			end
		end
	end
})

ix.command.Add("PlyNotarget", {
	syntax = "<string Player>",
	adminOnly = true,
	description = "Toggle notarget for a player.",
	arguments = {ix.type.character, bit.bor(ix.type.bool, ix.type.optional)},
	OnRun = function(self, client, target, silent)
		if SERVER then
			if target then
				serverguard.command.Run(client, "npctarget", (silent or false), target.player:Name())
			end
		end
	end
})

ix.command.Add("PlyGod", {
	syntax = "<string Player>",
	adminOnly = true,
	description = "Toggle God Mode for a player.",
	arguments = {ix.type.character, bit.bor(ix.type.bool, ix.type.optional)},
	OnRun = function(self, client, target, silent)
		if SERVER then
			if target then
				serverguard.command.Run(client, "god", silent or false, target.player:Name())
			end
		end
	end
})

ix.command.Add("PlyFreeze", {
	syntax = "<string Player>",
	adminOnly = true,
	description = "Toggle Freezing for a player.",
	arguments = {ix.type.character, bit.bor(ix.type.bool, ix.type.optional)},
	OnRun = function(self, client, target, silent)
		if SERVER then
			if target then
				serverguard.command.Run(client, "freeze", silent or false, target.player:Name())
			end
		end
	end
})

ix.command.Add("PlySetGroup", {
	syntax = "<string Player>",
	adminOnly = true,
	description = "Set a player's group.",
	arguments = {ix.type.character, ix.type.string, bit.bor(ix.type.number, ix.type.optional)},
	OnRun = function(self, client, target, rank, length)
		if SERVER then
			if target then
				serverguard.command.Run(client, "setrank", silent or false, target.player:Name(), rank, length or 0)
			end
		end
	end
})

ix.command.Add("PlyDemote", {
	syntax = "<string Player>",
	adminOnly = true,
	description = "Demote a player to user.",
	arguments = ix.type.character,
	OnRun = function(self, client, target)
		if SERVER then
			if target then
				serverguard.command.Run(client, "setrank", silent or false, target.player:Name(), "user", 0)
			end
		end
	end
})

ix.command.Add("Respawn", {
	syntax = "<string Player>",
	adminOnly = true,
	description = "Respawn a player.",
	arguments = {ix.type.character, bit.bor(ix.type.string, ix.type.optional)},
	OnRun = function(self, client, target, silent)
		if SERVER then
			if target then
				serverguard.command.Run(client, "respawn", silent or false, target.player:Name())
			end
		end
	end
})

ix.command.Add("RespawnBring", {
	syntax = "<string Player>",
	adminOnly = true,
	description = "Respawn a player and teleport them to your target location.",
	arguments = {ix.type.character, bit.bor(ix.type.string, ix.type.optional)},
	OnRun = function(self, client, target, silent)
		if SERVER then
			if target then
				serverguard.command.Run(client, "respawn", silent or false, target.player:Name())
				serverguard.command.Run(client, "send", true, target.player:Name())
			end
		end
	end
})

ix.command.Add("RespawnStay", {
	syntax = "<string Player>",
	adminOnly = true,
	description = "Respawn a player at their current location.",
	arguments = {ix.type.character, bit.bor(ix.type.string, ix.type.optional)},
	OnRun = function(self, client, target, silent)
		if SERVER then
			if target then
				local pos = target.player:GetPos()
				serverguard.command.Run(client, "respawn", silent or true, target.player:Name())
				target.player:SetPos(pos)
			end
		end
	end
})

ix.command.Add("CharTie", {
	syntax = "<string Player>",
	adminOnly = true,
	description = "Tie a player.",
	arguments = {ix.type.character},
	OnRun = function(self, client, target, silent)
		if SERVER then
			if target then
				target.player:SetNetVar("restricted", not target.player:GetNetVar("restricted"))

				if target.player:GetNetVar("restricted") then
					client:Notify("You have tied " .. target.player:Name() .. ".")
					target.player:Notify("You have been tied by an admin.")
				else
					client:Notify("You have untied " .. target.player:Name() .. ".")
					target.player:Notify("You have been untied by an admin.")
				end
			end
		end
	end
})

ix.command.Add("Eventd", {
	description = "Send an event directly to a character",
	adminOnly = true,
	arguments = {
		ix.type.player,
		ix.type.text
	},
	OnRun = function(self, client, target, message)
		local voiceMail = target:GetData("vm")

		if ((client.ixNextPM or 0) < CurTime()) then
			ix.chat.Send(client, "eventd", message, false, {client, target}, {target = target})

			client.ixNextPM = CurTime() + 0.5
			target.ixLastPM = client
		end
	end
})

if CLIENT then
    -- Function to create the log viewing panel
    net.Receive("ixViewChatLog", function()
        local logData = net.ReadString()

        -- Create the frame
        local frame = vgui.Create("DFrame")
        frame:SetTitle("AUDIO TRANSCRIPT")
        frame:SetSize(600, 800)
        frame:Center()
        frame:MakePopup()

        -- Create the scroll panel
        local scrollPanel = frame:Add("DScrollPanel")
        scrollPanel:Dock(FILL)

        -- Create the text box
        local textEntry = scrollPanel:Add("DTextEntry")
        textEntry:SetMultiline(true)
        textEntry:SetSize(600, 800)
        textEntry:SetText(logData)
        textEntry:SetEditable(false)
    end)
end

if SERVER then
    -- Networking setup
    util.AddNetworkString("ixViewChatLog")

    ix.command.Add("ViewChatLog", {
        syntax = "<string LoggerName>",
        adminOnly = true,
        description = "View the IC chat logs of a specified logger.",
        arguments = {ix.type.string},

        OnRun = function(self, client, loggerName)
            local character = client:GetCharacter()
            if not character then return "You do not have a valid character." end

            -- Check if the player is either an admin OR in the Combine faction
            if not client:IsAdmin() and character:GetFaction() ~= FACTION_MPF then
                return "You do not have permission to view chat logs."
            end

            -- Generate the expected filename based on logger name
            local fileName = "ic_chat_log_" .. loggerName .. ".txt"

            -- Check if the file exists
            if not file.Exists(fileName, "DATA") then
                return "NO INFORMATION FOUND FOR: " .. loggerName
            end

            -- Read the file content
            local logData = file.Read(fileName, "DATA")
            if not logData or logData == "" then
                return "The log file is empty."
            end

            -- Send the data to the client for display in a UI panel
            net.Start("ixViewChatLog")
            net.WriteString(logData)
            net.Send(client)
        end
    })
end

if SERVER then
    -- Register the network string BEFORE attempting to use it
    util.AddNetworkString("ixRequestChatLog")

    net.Receive("ixRequestChatLog", function(len, client)
        local loggerName = net.ReadString():Trim()
        if loggerName == "" then
            loggerName = "default"
        end

        local fileName = "ic_chat_log_" .. loggerName .. ".txt"
        if not file.Exists(fileName, "DATA") then
            client:Notify("NO INFORMATION FOUND FOR: " .. loggerName)
            return
        end

        local logData = file.Read(fileName, "DATA")
        if not logData or logData == "" then
            client:Notify("The log file is empty.")
            return
        end

        -- Send log data to the client
        net.Start("ixViewChatLog") -- Ensure "ixViewChatLog" is also registered
        net.WriteString(logData)
        net.Send(client)
    end)
end

------material window for combine display testting

ix.command.Add("showdisplay", {
    description = "Opens a display with a chosen material.",
    arguments = {ix.type.string},
    OnRun = function(self, client, materialPath)
        if not materialPath or materialPath == "" then
            client:Notify("You must provide a valid material path.")
            return
        end

        if not file.Exists("materials/" .. materialPath .. ".vtf", "GAME") then
            client:Notify("Invalid material path. Ensure it exists.")
            return
        end

        net.Start("ShowDisplayUI")
        net.WriteString(materialPath)
        net.Send(client)
    end
})

if SERVER then
    util.AddNetworkString("ShowDisplayUI")
end

if CLIENT then
    local function CreateMaterialFrame(materialPath)
        local frame = vgui.Create("DFrame")
        frame:SetTitle("")
        frame:SetSize(620, 600)
        frame:Center()
        frame:MakePopup()
        frame:SetDraggable(false) -- Prevents dragging
        frame:ShowCloseButton(true)
        frame.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(50, 50, 50, 0)) -- Thinner frame
        end

        local panel = vgui.Create("DPanel", frame)
        panel:SetSize(570, 570)
        panel:SetPos(10, 10)

        local mat = Material(materialPath)

        panel.Paint = function(self, w, h)
            if mat:IsError() then
                draw.SimpleText("Material not found!", "DermaLarge", w / 2, h / 2, Color(255, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                return
            end

            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(mat)
            surface.DrawTexturedRect(0, 0, w, h)
        end
    end

    net.Receive("ShowDisplayUI", function()
        local materialPath = net.ReadString()
        CreateMaterialFrame(materialPath)
    end)
end



------

PLUGIN.name = "Autowalk"
PLUGIN.author = "Nicholas"
PLUGIN.description = "Binds the N key to toggle autowalk."

if (CLIENT) then
    local isAutoWalking = false

    -- Toggles autowalk on and off
    local function ToggleAutowalk()
        isAutoWalking = not isAutoWalking
        RunConsoleCommand(isAutoWalking and "+forward" or "-forward")
    end

    -- Handles autowalk toggle on N key press
    hook.Add("PlayerButtonDown", "AutowalkToggle", function(ply, button)
        if (button == KEY_N) then
            ToggleAutowalk()
        end
    end)

    -- Stops autowalk when manual movement keys are pressed
    hook.Add("PlayerButtonDown", "AutowalkDisableOnMove", function(ply, button)
        if isAutoWalking and (button == KEY_W or button == KEY_S or button == KEY_A or button == KEY_D) then
            ToggleAutowalk()
        end
    end)
end

----
