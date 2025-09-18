PLUGIN.name = "Blue's entities"
PLUGIN.author = "Blue and Copilot"
PLUGIN.description = "Provides chat logger entities and functionality, washing machines and more."



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