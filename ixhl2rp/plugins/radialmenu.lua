local PLUGIN = PLUGIN

PLUGIN.name = "Radial Chat Menu"
PLUGIN.author = "Nicholas"
PLUGIN.description = "Adds a radial menu bound to G that types predefined phrases in chat using console commands, with options depending on character gender."

if (CLIENT) then
    local currentMenu -- Keep track of the currently open menu

    -- Gender-specific phrases
    local malePhrases = {
        {menuText = "Stand", subMenu = {
            {menuText = "Idle", chatText = "/actstand 1"},
            {menuText = "Arms Crossed", chatText = "/actstand 2"},
            {menuText = "Antsy", chatText = "/actstand 3"},
            {menuText = "Hands in Pockets", chatText = "/actstand 4"}
        }},
        {menuText = "Sit", subMenu = {
            {menuText = "Ground", chatText = "/actsit 3"},
            {menuText = "Chair", chatText = "/actsit 4"}
        }},
        {menuText = "Lean", subMenu = { 
            {menuText = "Legs Crossed", chatText = "/actlean 1"}, 
            {menuText = "Hands Back", chatText = "/actlean 2"}, 
            {menuText = "Relaxed", chatText = "/actlean 3"} 
        }},
        {menuText = "Cheer", chatText = "/actcheer"},
        {menuText = "Wave", subMenu = {
            {menuText = "Far", chatText = "/actwave 1"},
            {menuText = "Close", chatText = "/actwave 2"}
        }},
        {menuText = "Pant", subMenu = { 
            {menuText = "Standing", chatText = "/actpant 1"}, 
            {menuText = "Against wall", chatText = "/actpant 2"} 
        }},
        {menuText = "Window", chatText = "/actwindow"},
        {menuText = "Arrest", subMenu = { 
            {menuText = "Floor", chatText = "/actarrest"}, 
            {menuText = "Pat down", chatText = "/actarrestwall 1"},
            {menuText = "Hands over head", chatText = "/actarrestwall 2"}
        }},
        {menuText = "Kneel", subMenu = { 
            {menuText = "Checking", chatText = "/actkneel 1"}, 
            {menuText = "Hand rested", chatText = "/actkneel 2"},
            {menuText = "Holding Weapon", chatText = "/actkneelweapon"}
        }},
        {menuText = "Search", chatText = "/actsearch"},
        {menuText = "Down", subMenu = { 
            {menuText = "Agonized", chatText = "/actdown 1"}, 
            {menuText = "Wounded", chatText = "/actdown 2"},
            {menuText = "Hurt", chatText = "/actdown 3"},
            {menuText = "Face down", chatText = "/actdown 4"}
        }},
    }

    local femalePhrases = {
        {menuText = "Stand", subMenu = {
            {menuText = "Arms Crossed", chatText = "/actstand 1"},
            {menuText = "Hand Over Hand", chatText = "/actstand 2"},
            {menuText = "Hand Under Chin", chatText = "/actstand 3"}
        }},
        {menuText = "Sit", subMenu = {
            {menuText = "Sit Ground", chatText = "/actsit 1"},
            {menuText = "Sit Chair", chatText = "/actsit 2"}
        }},
        {menuText = "Lean", subMenu = { 
            {menuText = "Legs Crossed", chatText = "/actlean 1"}, 
            {menuText = "Hands Back", chatText = "/actlean 2"}, 
            {menuText = "Relaxed", chatText = "/actlean 3"} 
        }},
        {menuText = "Cheer", chatText = "/actcheer"},
        {menuText = "Wave", subMenu = {
            {menuText = "Far", chatText = "/actwave 1"},
            {menuText = "Close", chatText = "/actwave 2"}
        }},
        {menuText = "Pant", subMenu = { 
            {menuText = "Standing", chatText = "/actpant 1"}, 
            {menuText = "Against wall", chatText = "/actpant 2"} 
        }},
        {menuText = "Window", chatText = "/actwindow"},
        {menuText = "Kneel", subMenu = { 
            {menuText = "Knees", chatText = "/actkneel 1"}, 
            {menuText = "Concerned", chatText = "/actkneel 2"},
            {menuText = "Check", chatText = "/actkneel 3"}
        }},
        {menuText = "Search", chatText = "/actsearch"},
        {menuText = "Down", subMenu = { 
            {menuText = "On Side", chatText = "/actdown 1"}, 
            {menuText = "Supine", chatText = "/actdown 2"},
        }},
    }

    -- Opens the radial menu based on gender
    function PLUGIN:OpenRadialMenu()
        -- Close the current menu if it exists
        if IsValid(currentMenu) then
            currentMenu:Remove()
            currentMenu = nil
        end

        -- Determine the player's gender
        local phrases = LocalPlayer():GetModel():find("female") and femalePhrases or malePhrases

        -- Create the menu
        local menu = vgui.Create("DMenu")
        currentMenu = menu -- Track the current menu

        menu:SetDrawBackground(false)
        menu.Paint = function(self, w, h)
            draw.RoundedBox(8, 0, 0, w, h, Color(40, 40, 40, 230)) -- Custom background
        end

        -- Populate the menu with gender-based phrases
        for _, phrase in ipairs(phrases) do
            if phrase.subMenu then
                -- Create submenu for options
                local subMenu, parentOption = menu:AddSubMenu(phrase.menuText)
                subMenu.Paint = function(self, w, h)
                    draw.RoundedBox(8, 0, 0, w, h, Color(50, 50, 50, 230)) -- Custom submenu background
                end

                for _, subOption in ipairs(phrase.subMenu) do
                    subMenu:AddOption(subOption.menuText, function()
                        RunConsoleCommand("say", subOption.chatText)
                    end):SetTextColor(Color(255, 255, 255)) -- White text
                end

                parentOption:SetTextColor(Color(255, 200, 50)) -- Highlighted text color for parent option
            else
                -- Add normal options without submenus
                menu:AddOption(phrase.menuText, function()
                    RunConsoleCommand("say", phrase.chatText)
                end):SetTextColor(Color(255, 255, 255)) -- White text
            end
        end

        menu:Open()
        menu:Center()
    end

    -- Bind the radial menu to G key
    hook.Add("PlayerButtonDown", "RadialChatMenuBind", function(ply, button)
        if (button == KEY_G) then
            PLUGIN:OpenRadialMenu()
        end
    end)
end 