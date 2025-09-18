DEFINE_BASECLASS("base_gmodentity")

ENT.Type = "anim"
ENT.Author = "Aspect™ & Trudeau"
ENT.PrintName = "Camera Terminal"
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
            self:EmitSound("ambient/machines/keyboard1_clicks.wav", 60)
            self:EmitSound("buttons/combine_button1.wav", 60)
        end
        return options
    end

    -- If a camera has been selected, offer additional options.
    if IsValid(self.SelectedCamera) then
        options["Main Screen"] = function()
            self:SetNWEntity("camera", self)
            self.SelectedCamera = nil -- Reset camera selection
                local sounds = {
                "ambient/machines/keyboard1_clicks.wav",
                "ambient/machines/keyboard2_clicks.wav",
                "ambient/machines/keyboard3_clicks.wav",
                "ambient/machines/keyboard4_clicks.wav",
                "ambient/machines/keyboard5_clicks.wav",
                "ambient/machines/keyboard6_clicks.wav",
                "ambient/machines/keyboard_slow_1second.wav"
            }
        self:EmitSound(sounds[math.random(#sounds)], 60)
        end

        local camera = self.SelectedCamera
        local currentSeq = camera:GetSequenceName(camera:GetSequence())

        -- If the camera is enabled ("idle"), show Disable option.
        if (currentSeq == "idlealert") then
            options["Disable Camera"] = function()
                if SERVER then
                    net.Start("ixDisableCamera")
                        net.WriteEntity(camera)
                    net.SendToServer()
                else
                    net.Start("ixDisableCamera")
                        net.WriteEntity(camera)
                    net.SendToServer()
                end
            local sounds = {
                "ambient/machines/keyboard1_clicks.wav",
                "ambient/machines/keyboard2_clicks.wav",
                "ambient/machines/keyboard3_clicks.wav",
                "ambient/machines/keyboard4_clicks.wav",
                "ambient/machines/keyboard5_clicks.wav",
                "ambient/machines/keyboard6_clicks.wav",
                "ambient/machines/keyboard_slow_1second.wav"
            }
            self:EmitSound(sounds[math.random(#sounds)], 60)
        end
        -- If the camera is disabled ("idlealert"), show Enable option.
        elseif (currentSeq == "idle") then
            options["Enable Camera"] = function()
                if SERVER then
                    net.Start("ixEnableCamera")
                        net.WriteEntity(camera)
                    net.SendToServer()
                else
                    net.Start("ixEnableCamera")
                        net.WriteEntity(camera)
                    net.SendToServer()
                end
            end
        end
    end

    options["Turn Off"] = function()
        self:SetSkin(1)
            self:EmitSound("ambient/machines/keyboard3_clicks.wav", 60)
            self:EmitSound("buttons/combine_button1.wav", 60)
        self:SetNWEntity("camera", self)
        self.SelectedCamera = nil -- Reset camera selection when turning off
    end

    -- Populate camera selection options dynamically.
    for _, v in pairs(ents.FindByClass("npc_combine_camera")) do
        options["View C-i" .. v:EntIndex()] = function()
            self:SetNWEntity("camera", v)
            self.SelectedCamera = v -- Store the selected camera.
            self:EmitSound("weapons/ar2/ar2_reload_rotate.wav", 60)
        end
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
        local sounds = {
            "ambient/machines/keyboard1_clicks.wav",
            "ambient/machines/keyboard2_clicks.wav",
            "ambient/machines/keyboard3_clicks.wav",
            "ambient/machines/keyboard4_clicks.wav",
            "ambient/machines/keyboard5_clicks.wav",
            "ambient/machines/keyboard6_clicks.wav",
            "ambient/machines/keyboard_slow_1second.wav"
        }
        self:EmitSound(sounds[math.random(#sounds)], 60)
    end

    options["Search Data"] = function()
        if CLIENT then
            net.Start("ixOpenDatapad")
            net.SendToServer()
        end
        local sounds = {
            "ambient/machines/keyboard1_clicks.wav",
            "ambient/machines/keyboard2_clicks.wav",
            "ambient/machines/keyboard3_clicks.wav",
            "ambient/machines/keyboard4_clicks.wav",
            "ambient/machines/keyboard5_clicks.wav",
            "ambient/machines/keyboard6_clicks.wav",
            "ambient/machines/keyboard_slow_1second.wav"
        }
        self:EmitSound(sounds[math.random(#sounds)], 60)
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