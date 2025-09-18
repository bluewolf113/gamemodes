-- ENV_EVENT CLIENT ANIMATION

-- Active messagePanel instances
local activeMessagePanels = {}

net.Receive("ShowEnvEventMessage", function()
    local message = net.ReadString()

    -- Split the message by commas and trim whitespace
    local messages = string.Split(message, ",")
    for i, msg in ipairs(messages) do
        messages[i] = string.Trim(msg)
    end

    -- Function to create and display a message panel
    local function createMessagePanel(msg, delay)
        timer.Simple(delay, function()
            local messagePanel = vgui.Create("DPanel")
            messagePanel:SetSize(ScrW(), ScrH() * 0.1)

            -- Calculate Y pos for new messagePanel
            local yPos = ScrH() * 0.55
            for _, panel in ipairs(activeMessagePanels) do
                yPos = yPos + (panel:GetTall() / 2) -- Add the height of each existing panel
            end
            messagePanel:SetPos(0, yPos)

            local currentText = ""
            local charIndex = 1
            local alpha = 255
            local fadeDuration = 2 -- Duration of fade-out in seconds
            local flashAlpha = 0 -- Initial alpha for the flash effect
            local flashChar = "" -- Character to flash

            -- Update displayed text
            local function updateText()
                if charIndex <= #msg then
                    currentText = string.sub(msg, 1, charIndex)
                    flashChar = string.sub(msg, charIndex, charIndex)
                    charIndex = charIndex + 1

                    -- Reset flash alpha when new char added
                    flashAlpha = 255

                    -- Timer to decrease flash alpha
                    timer.Create("FlashEffect_" .. tostring(messagePanel), 0.05, 5, function()
                        flashAlpha = math.max(flashAlpha - 51, 0) -- Fade out over 0.25 seconds
                    end)
                end
            end

            messagePanel.Paint = function(self, w, h)
                -- Background color
                surface.SetDrawColor(0, 0, 0, 200)

                -- Text settings
                surface.SetFont("HudDefault")

                -- Draw underlying text
                surface.SetTextColor(210, 210, 210, alpha)
                local textW, textH = surface.GetTextSize(msg) -- Calculate width with full message
                surface.SetTextPos((w - textW) / 2, (h - textH) / 2) -- Center using full message width
                surface.DrawText(currentText)

                -- Draw flash text
                if flashAlpha > 0 and flashChar ~= "" then
                    local currentTextW = surface.GetTextSize(currentText)
                    surface.SetTextColor(255, 165, 0, flashAlpha) -- Orange color
                    surface.SetTextPos((w - textW) / 2 + currentTextW - surface.GetTextSize(flashChar), (h - textH) / 2) -- Position for flashing character
                    surface.DrawText(flashChar)
                end
            end

            -- Add the new messagePanel to the active panels table
            table.insert(activeMessagePanels, messagePanel)

            -- Timer to update text
            timer.Create("TypewriterEffect_" .. tostring(messagePanel), 0.005, #msg, updateText)

            -- Fade-out timer
            timer.Simple(7, function()
                messagePanel.fadeOutTimer = timer.Create("FadeOutEffect_" .. tostring(messagePanel), 0.1, fadeDuration * 10, function()
                    alpha = math.max(alpha - (255 / (fadeDuration * 10)), 0)
                    if alpha <= 0 then
                        if IsValid(messagePanel) then
                            messagePanel:Remove()
                            -- Remove the messagePanel from the active panels table
                            table.RemoveByValue(activeMessagePanels, messagePanel)
                        end
                    end
                end)
            end)
        end)
    end

    -- Create message panels with a delay to ensure one finishes before the next starts
    local delay = 0
    for _, msg in ipairs(messages) do
        createMessagePanel(msg, delay)
        delay = delay + (#msg * 0.005) + 1 -- Typewriter time plus some buffer time
    end
end)
