local PLUGIN = PLUGIN

PLUGIN.name = "Action Menu"
PLUGIN.author = "Blue"
PLUGIN.description = "Adds a compact F1 action menu styled like the interact menu."

if SERVER then
    util.AddNetworkString("ixDrinkWater")

    net.Receive("ixDrinkWater", function(_, client)
        if not IsValid(client) or not client:Alive() then return end

        -- must be standing in water
        if client:WaterLevel() < 1 then
            client:Notify("You're not standing in water!")
            return
        end

        local liquid = ix.liquids.Get("waterraw")
        if not liquid then return end

        local volConsumed = 80

        -- apply liquid effects
        liquid:OnConsume(client, volConsumed)

        -- play sound
        client:EmitSound(liquid:GetConsumeSound())
    end)
else
    -- Toggle menu on F1 press
    hook.Add("PlayerButtonDown", "ActionMenuBindF1", function(ply, button)
        if button == KEY_F1 then
            if IsValid(ix.gui.actionMenu) then
                ix.gui.actionMenu:Destroy()
            else
                vgui.Create("ixActionMenu")
            end
        end
    end)

    -- PANEL definition styled like ixInteractMenu
    local PANEL = {}

    function PANEL:Init()
        if IsValid(ix.gui.actionMenu) then
            ix.gui.actionMenu:Destroy()
        end

        ix.gui.actionMenu = self
        self.options = {}

        -- wider menu
        self:SetSize(260, 12)
        self:MakePopup()
        self:Center()

        -- Add options
        self:AddOption({
            name = "Fall Over",
            icon = "icon16/arrow_down.png",
            callback = function()
                RunConsoleCommand("say", "/charfallover")
            end
        })

        self:AddOption({
            name = "Drink Water",
            icon = "icon16/cup.png",
            callback = function()
                net.Start("ixDrinkWater")
                net.SendToServer()
            end
        })

        self:Build()
    end

    function PANEL:Build()
        local newHeight = 12
        for _ in pairs(self.options) do
            newHeight = newHeight + 28
        end
        self:SetTall(newHeight)
    end

    function PANEL:AddOption(data)
        local option = self:Add("DButton")
        option:SetText("")
        option:Dock(TOP)
        option:SetTall(24)
        option:DockMargin(6, (#self.options < 1) and 6 or 0, 6, 0)

        option.Paint = function()
            if option:IsHovered() then
                surface.SetDrawColor(90, 90, 90, 150)
                surface.DrawRect(0, 0, option:GetWide(), option:GetTall())
            end

            ix.util.DrawText(data.name, 32, 5, color_white, 0, 0, "ixSmallFont")
        end

        option.DoClick = function()
            if data.callback then
                data.callback()
            end
            self:Destroy()
        end

        if data.icon then
            local icon = option:Add("DImage")
            icon:SetSize(16, 16)
            icon:SetPos(8, 4)
            icon:SetMaterial(data.icon)
            icon.AutoSize = false
        end

        table.insert(self.options, option)
    end

    function PANEL:Destroy()
        self:Remove()
        ix.gui.actionMenu = nil
    end

    function PANEL:OnRemove()
        if ix and ix.gui and ix.gui.actionMenu == self then
            ix.gui.actionMenu = nil
        end
    end

    function PANEL:Paint(w, h)
        surface.SetDrawColor(25, 25, 25, 225)
        surface.DrawRect(0, 0, w, h)

        surface.SetDrawColor(90, 90, 90, 255)
        surface.DrawOutlinedRect(0, 0, w, h)
    end

    vgui.Register("ixActionMenu", PANEL, "DPanel")
end
