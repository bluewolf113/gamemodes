PLUGIN.name = "Extra Character Subpanel"
PLUGIN.author = "YourName"
PLUGIN.description = "Adds an extra blank subpanel between the description and skills panels in character creation."

if (CLIENT) then
    hook.Add("CreateCharacterMenuPanels", "ExtraCharacterSubpanel", function(menu)
        -- Create the extra subpanel.
        local extraPanel = menu:AddSubpanel("extrapanel")
        extraPanel:SetTitle("Extra Panel")
        extraPanel:SetVisible(false) -- It will be shown when the user navigates to this step.
        
        -- For testing, draw some text so you can see the panel.
        extraPanel.Paint = function(self, w, h)
            draw.SimpleText("This panel is intentionally left blank.", "Default", w/2, h/2, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        
        -- Add a Continue button at the bottom of the panel.
        local continueButton = extraPanel:Add("ixMenuButton")
        continueButton:SetText("Continue")
        continueButton:Dock(BOTTOM)
        continueButton:SizeToContents()
        continueButton.DoClick = function()
            -- Progress to the next subpanel.
            menu:NextPanel()
        end
    end)
end
