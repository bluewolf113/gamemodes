local PLUGIN = PLUGIN

PLUGIN.name = "Action Menu"
PLUGIN.author = "Blue"
PLUGIN.description = "Adds a compact F1 action menu styled like the interact menu."

if SERVER then
    util.AddNetworkString("ixDrinkWater")

    net.Receive("ixDrinkWater", function(_, client)
        if not IsValid(client) or not client:Alive() then return end

        if client:WaterLevel() >= 1 then
            client:EmitSound("ambient/water/drip2.wav")
            client:ChatPrint("You take a refreshing sip of water.")
        else
            client:ChatPrint("You're not standing in water!")
        end
    end)
else
    function PLUGIN:PlayerButtonDown(client, button)
        if button == KEY_F1 then
            if IsValid(ix.gui.actionMenu) then
                ix.gui.actionMenu:Destroy()
            else
                vgui.Create("ixActionMenu")
            end
        end
    end

    -- PANEL definition styled like ixInteractMenu
    local PANEL = {}

    function PANEL:Init()
        if IsValid(ix.gui.actionMenu) then
            ix.gui.actionMenu:Destroy()
        end

        ix.gui.actionMenu = self
        self.options = {}

        self:SetSize(160, 12)
        self:MakePopup()
        self:Center()

        -- Add our two options
        self:AddOption({
            name = "Change Character Status",
            icon = "icon16/user.png",
            callback = function()
                vgui.Create("ixStatusMenu")
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
        local newHeight = self:GetTall()
        for _, v in pairs(self.options) do
            newHeight = newHeight + 24
        end
        self:SetTall(newHeight)
    end

    function PANEL:AddOption(data)
        local option = self:Add("DButton")
        option:SetText("")
        option:Dock(TOP)
        option:SetTall(24)
        option.Paint = function()
            if option:IsHovered() then
                surface.SetDrawColor(90, 90, 90, 150)
                surface.DrawRect(0, 0, option:GetWide(), option:GetTall())
            end

            ix.util.DrawText(data.name, 24, 4, color_white, 0, 0, "ixSmallFont")
        end
        option.DoClick = function()
            if data.callback then
                data.callback()
            end
            self:Destroy()
        end

        option:DockMargin(6, (#self.options < 1) and 6 or 0, 6, 0)

        if data.icon then
            local icon = option:Add("DImage")
            icon:SetSize(12, 12)
            icon:SetPos(4, 6)
            icon:SetMaterial(data.icon)
            icon.AutoSize = false
        end

        table.insert(self.options, option)
    end

    function PANEL:Destroy()
        self:Remove()
        ix.gui.actionMenu = nil
    end

    function PANEL:Paint(w, h)
        surface.SetDrawColor(25, 25, 25, 225)
        surface.DrawRect(0, 0, w, h)

        surface.SetDrawColor(90, 90, 90, 255)
        surface.DrawOutlinedRect(0, 0, w, h)
    end

    vgui.Register("ixActionMenu", PANEL, "DPanel")
end
