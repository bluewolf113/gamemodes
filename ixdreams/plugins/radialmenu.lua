local PLUGIN = PLUGIN

PLUGIN.name = "Radial Chat Menu"
PLUGIN.author = "Nicholas"
PLUGIN.description = "Adds a radial menu bound to G that types predefined phrases in chat using console commands, with options depending on character gender."

if CLIENT then
    local currentMenu

    -- Phrase tables keyed by Helix model class
    local phrasesByClass = {
        citizen_male = {
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
            {menuText = "Standing Style", subMenu = {
                {menuText = "Normal", chatText = "/moodwalk 0"},
                {menuText = "Active", chatText = "/moodstand 1"},
                {menuText = "Arms Crossed", chatText = "/moodstand 2"},
                {menuText = "Agitated", chatText = "/moodstand 3"},
                {menuText = "Panicked", chatText = "/moodstand 4"}
            }},
            {menuText = "Walk Style", subMenu = {
                {menuText = "Normal", chatText = "/moodwalk 0"},
                {menuText = "Malaise", chatText = "/moodwalk 1"},
                {menuText = "Arms Crossed", chatText = "/moodwalk 2"},
                {menuText = "Calmly", chatText = "/moodwalk 3"},
                {menuText = "Panicked", chatText = "/moodwalk 4"}
            }},
            {menuText = "Run Style", subMenu = {
                {menuText = "Normal", chatText = "/moodrun 0"},
                {menuText = "Dash", chatText = "/moodrun 1"},
                {menuText = "Panicked", chatText = "/moodrun 2"},
                {menuText = "Low", chatText = "/moodrun 3"},
                {menuText = "Head Covered", chatText = "/moodrun 4"}
            }},
            {menuText = "Reset Moods", chatText = "/moodreset"}
        },

        citizen_female = {
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
                {menuText = "Supine", chatText = "/actdown 2"}
            }},
            {menuText = "Standing Style", subMenu = {
                {menuText = "Normal", chatText = "/moodstand 0"},
                {menuText = "Arms Crossed", chatText = "/moodstand 1"},
                {menuText = "Hands Together", chatText = "/moodstand 2"},
                {menuText = "Hand Under Chin", chatText = "/moodstand 3"}
            }},
            {menuText = "Walk Style", subMenu = {
                {menuText = "Normal", chatText = "/moodwalk 0"},
                {menuText = "Moderate", chatText = "/moodwalk 1"},
                {menuText = "Hands Together", chatText = "/moodwalk 3"},
                {menuText = "Panicked", chatText = "/moodwalk 2"}
            }},
            {menuText = "Run Style", subMenu = {
                {menuText = "Normal", chatText = "/moodrun 0"},
                {menuText = "Cautious", chatText = "/moodrun 1"},
                {menuText = "Head Covered", chatText = "/moodrun 2"},
                {menuText = "Face Guarded", chatText = "/moodrun 3"},
                {menuText = "Head Down", chatText = "/moodrun 4"},
                {menuText = "Protected", chatText = "/moodrun 5"}
            }},
            {menuText = "Reset Moods", chatText = "/moodreset"}
        },

        metrocop = {
            {menuText = "Hands Up", chatText = "/surrender"},
            {menuText = "Arrest", subMenu = {
                {menuText = "Floor", chatText = "/actarrest"},
                {menuText = "Pat Down", chatText = "/actarrestwall 1"},
                {menuText = "Hands Over Head", chatText = "/actarrestwall 2"}
            }},
            {menuText = "Radio", chatText = "/radio 1"},
            {menuText = "Search", chatText = "/actsearch"},
            {menuText = "Cuff", chatText = "/actcuff"},
            {menuText = "Reset Moods", chatText = "/moodreset"}
        },
        vortigaunt = {
            {menuText = "Stand", subMenu = {
                {menuText = "1", chatText = "/actstand 1"},
                {menuText = "2", chatText = "/actstand 2"},
                {menuText = "3", chatText = "/actstand 3"},
                {menuText = "4", chatText = "/actstand 4"}
            }},
            {menuText = "Sit", chatText = "/actsit 1"},
            {menuText = "Pray", chatText = "/actpray 1"},
            {menuText = "Kneel", chatText = "/actkneel"}
        }
    }

    function PLUGIN:OpenRadialMenu()
        if IsValid(currentMenu) then
            currentMenu:Remove()
            currentMenu = nil
        end

        local modelClass = ix.anim.GetModelClass(LocalPlayer():GetModel())
        local phrases = phrasesByClass[modelClass] or phrasesByClass.citizen_male

        local menu = vgui.Create("DMenu")
        currentMenu = menu
        menu:SetDrawBackground(false)
        menu.Paint = function(self, w, h)
            draw.RoundedBox(8, 0, 0, w, h, Color(40, 40, 40, 230))
        end

        for _, phrase in ipairs(phrases) do
            if phrase.subMenu then
                local subMenu, parent = menu:AddSubMenu(phrase.menuText)
                subMenu.Paint = function(self, w, h)
                    draw.RoundedBox(8, 0, 0, w, h, Color(50, 50, 50, 230))
                end

                for _, opt in ipairs(phrase.subMenu) do
                    subMenu:AddOption(opt.menuText, function()
                        RunConsoleCommand("say", opt.chatText)
                    end):SetTextColor(Color(255, 255, 255))
                end

                parent:SetTextColor(Color(255, 200, 50))
            else
                menu:AddOption(phrase.menuText, function()
                    RunConsoleCommand("say", phrase.chatText)
                end):SetTextColor(Color(255, 255, 255))
            end
        end

        menu:Open()
        menu:Center()
    end

    hook.Add("PlayerButtonDown", "RadialChatMenuBind", function(ply, button)
        if button == KEY_G then
            PLUGIN:OpenRadialMenu()
        end
    end)
end
