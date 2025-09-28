DEFINE_BASECLASS("base_gmodentity")

ENT.Type = "anim"
ENT.Author = "Aspect™ & Trudeau"
ENT.PrintName = "Combine Inferface Var. 1"
ENT.Category = "Helix"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.UsableInVehicle = true

if SERVER then
    util.AddNetworkString("ixRequestChatLog")
    util.AddNetworkString("ixPlayButtonAnim")
end

function ENT:GetEntityMenu(client)
    local options = {}

    if self:GetSkin() == 1 then
        options["Turn On"] = function()
            self:SetSkin(0)
            self:EmitSound("weapons/ar2/ar2_reload_rotate.wav", 60)
        end
        return options
    end

    options["Turn Off"] = function()
        self:SetSkin(1)
        self:EmitSound("weapons/ar2/ar2_reload_push.wav", 60)
        self:SetNWEntity("camera", self)
        self.SelectedCamera = nil -- Reset camera selection when turning off
    end

    options["Check Camera Audio Logs"] = function()
        if CLIENT then
            Derma_StringRequest(
                "Chat Log Lookup",
                "Enter chat log file name (without extension)",
                "",
                function(text)
                    net.Start("ixRequestChatLog")
                        net.WriteString(text:Trim())
                    net.SendToServer()
                end,
                function() end
            )
        end
    end

    options["Search Data"] = function()
        if CLIENT then
            net.Start("ixOpenDatapad")
            net.SendToServer()
        end
    end

    return options
end


function ENT:PlayButtonAnim(client)
    if CLIENT then
        LocalPlayer():ConCommand("ix_act_button")
    elseif SERVER and IsValid(client) then
        net.Start("ixPlayButtonAnim")
        net.Send(client)
    end
end

if CLIENT then
    net.Receive("ixPlayButtonAnim", function()
        LocalPlayer():ConCommand("ix_act_button")
    end)
end