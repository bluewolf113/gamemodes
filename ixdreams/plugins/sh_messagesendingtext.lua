PLUGIN.name = "IxTVMessageTimer"
PLUGIN.author = "YourName"
PLUGIN.description = "Runs /event command every 10 seconds using parsed config text."

ix.config.Add("tvMessageText", "hello. welcome. enjoy your stay.", "Our text here for hello", nil, {
    category = "IxTVMessageTimer"
})

local currentIndex = 1
local parsedMessages = {}

local function ParseMessages()
    parsedMessages = {}

    local rawText = ix.config.Get("tvMessageText", "")
    for segment in string.gmatch(rawText, "([^%.]+)%.%s*") do
        local clean = segment:Trim()
        if clean ~= "" then
            table.insert(parsedMessages, clean)
        end
    end

    currentIndex = 1
end

-- Only run this logic on the server
timer.Create("autoEventHello", 10, 0, function()
    if #parsedMessages == 0 then return end

    ix.chat.Send(nil, "event", parsedMessages[currentIndex])
    currentIndex = currentIndex % #parsedMessages + 1
end
