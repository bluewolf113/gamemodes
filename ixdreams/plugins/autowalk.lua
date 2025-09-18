PLUGIN.name = "Autowalk"
PLUGIN.author = "Blue and Copilot"
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