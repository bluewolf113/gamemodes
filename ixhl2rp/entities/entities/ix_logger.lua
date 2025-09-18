AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Chat Logger"
ENT.Author = "YourName"
ENT.Category = "Helix"
ENT.Spawnable = true
ENT.AdminOnly = false -- Allow all players to interact with it

if SERVER then
    function ENT:Initialize()
        self:SetModel("models/gibs/shield_scanner_gib1.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetUseType(SIMPLE_USE)

        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:Wake()
        end

        local entIndex = self:EntIndex()
        if not self:GetNetVar("uniqueName") then
            self:SetNetVar("uniqueName", "Logger_" .. entIndex)
        end

        self.HookName = "ixIcChatLogger_" .. entIndex

        local NORMAL_RADIUS = 300
        local WHISPER_RADIUS = 280 * 0.25
        local YELL_RADIUS = 280 * 1.5
        local radiusSqrMap = {
            normal = NORMAL_RADIUS * NORMAL_RADIUS,
            whisper = WHISPER_RADIUS * WHISPER_RADIUS,
            yell = YELL_RADIUS * YELL_RADIUS,
            action = NORMAL_RADIUS * NORMAL_RADIUS -- For /me actions, default to normal range
        }

        local string_lower = string.lower
        local string_sub = string.sub
        local string_format = string.format
        local dateGet = ix.date.Get

        -- Hook to log nearby chat messages only if they are allowed
        hook.Add("PlayerSay", self.HookName, function(ply, text, teamChat, isDead)
            if not ply:GetCharacter() then return nil end

            local msgType = "normal"
            local lowerText = string_lower(text or "")

            if lowerText:StartWith("/y ") then
                msgType = "yell"
                text = string_sub(text, 4)
            elseif lowerText:StartWith("/w ") then
                msgType = "whisper"
                text = string_sub(text, 4)
            elseif lowerText:StartWith("/me ") then
                msgType = "action"
                text = string_sub(text, 5)
            elseif lowerText:StartWith("/") then
                -- If it starts with "/" but isn't /y, /w, or /me, do not log it
                return nil
            end

            local effectiveRadiusSqr = radiusSqrMap[msgType] or radiusSqrMap.normal
            local plyPos = ply:GetPos()
            local loggerPos = self:GetPos()

            if plyPos:DistToSqr(loggerPos) <= effectiveRadiusSqr then
                local gameTime = dateGet() or {}
                local formattedDate = string_format("%02d/%02d/%04d %02d:%02d:%02d",
                    gameTime.month or 1, gameTime.day or 1, gameTime.year or 2025,
                    gameTime.hour or 0, gameTime.minute or 0, gameTime.second or 0)

                local uniqueName = self.UniqueName or self:GetNetVar("uniqueName", "Logger_" .. entIndex)
                local fileName = "ic_chat_log_" .. uniqueName .. ".txt"

                local logLine
                if msgType == "action" then
                    logLine = string_format("[%s] %s %s\n", formattedDate, ply:Name(), text)
                else
                    local action = (msgType == "whisper" and "whispered") or (msgType == "yell" and "yelled") or "said"
                    logLine = string_format("[%s] %s %s: %s\n", formattedDate, ply:Name(), action, text)
                end

                file.Append(fileName, logLine)
            end

            return nil -- Allow normal chat processing.
        end)
    end

    function ENT:OnRemove()
        if self.HookName then
            hook.Remove("PlayerSay", self.HookName)
        end
    end

    function ENT:SetUniqueName(uniqueName)
        self.UniqueName = uniqueName
        self:SetNetVar("uniqueName", uniqueName)
    end

    function ENT:SpawnFunction(client, trace, className)
        if not trace.Hit then return end

        local ent = ents.Create(className)
        if not IsValid(ent) then return end

        ent:SetPos(trace.HitPos + trace.HitNormal * 16)
        ent:Spawn()
        ent:Activate()
        ent.Spawner = client

        timer.Simple(0.1, function()
            if IsValid(client) and IsValid(ent) then
                client:RequestString("Enter a unique name for the Chat Logger", "Unique Name", function(text)
                    if text == "" then
                        text = "Logger_" .. ent:EntIndex()
                    end
                    ent:SetUniqueName(text)
                    client:Notify("Chat Logger unique name set to: " .. text)
                end)
            end
        end)

        return ent
    end
end

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
    end
end
