AddCSLuaFile()
DEFINE_BASECLASS("base_gmodentity")

ENT.Type              = "anim"
ENT.Base              = "base_gmodentity"
ENT.PrintName         = "Inspectable Prop (Simple)"
ENT.Category          = "Helix"
ENT.Spawnable         = true
ENT.AdminOnly         = true
ENT.PopulateEntityInfo= true

if SERVER then
    util.AddNetworkString("ixInspectablePropUpdate")

    function ENT:Initialize()
        local mdl = self:GetNetVar("model",
                    self.Model or
                    "models/hunter/blocks/cube05x05x05.mdl"
                )
        self:SetModel(mdl)

        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)

        local phys = self:GetPhysicsObject()
        if IsValid(phys) then phys:Wake() end
    end

    net.Receive("ixInspectablePropUpdate", function(_, ply)
        if not ply:IsAdmin() then return end

        local ent  = net.ReadEntity()
        local key  = net.ReadString()
        local val  = net.ReadString()

        if not IsValid(ent)
        or ent:GetClass() ~= "ix_inspectable_prop" then
            return
        end

        ent:SetNetVar(key, val)

        if key == "model" then
            ent:SetModel(val)
            ent:PhysicsInit(SOLID_VPHYSICS)

            local phys = ent:GetPhysicsObject()
            if IsValid(phys) then phys:Wake() end
        end
    end)
end

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
    end

    function ENT:OnPopulateEntityInfo(tooltip)
        local name = self:GetNetVar("dispName", "Unmarked Object")
        local desc = self:GetNetVar("desc", "It doesn’t seem remarkable.")

        if name == "" and desc == "" then return end

        if name ~= "" then
            local title = tooltip:AddRow("name")
            title:SetText(name)
            title:SetImportant()
            title:SizeToContents()
        end

        if desc ~= "" then
            local panel = tooltip:AddRow("desc")
            panel:SetText(desc)
            panel:SizeToContents()
        end
    end

    function ENT:GetEntityMenu(ply)
        local inspectLabel = self:GetNetVar("inspectLabel", "Inspect")
        local inspectMsg = self:GetNetVar("inspectMsg",
            "You examine it, but find nothing unusual."
        )

        return {
            [inspectLabel] = function()
                ply:ChatPrint(inspectMsg)
            end
        }
    end
end

-- Pull out all properties.Add calls into their own section
    properties.Add("ix_set_dispname", {
        MenuLabel = "Set Display Name",
        Order     = 1,
        MenuIcon  = "icon16/font.png",

        Filter = function(self, ent, ply)
            return IsValid(ent)
               and ent:GetClass() == "ix_inspectable_prop"
               and ply:IsAdmin()
        end,

        Action = function(self, ent)
            Derma_StringRequest(
                "Set Display Name", "Enter new display name:",
                ent:GetNetVar("dispName", ""),
                function(input)
                    net.Start("ixInspectablePropUpdate")
                        net.WriteEntity(ent)
                        net.WriteString("dispName")
                        net.WriteString(input)
                    net.SendToServer()
                end
            )
        end
    })

    properties.Add("ix_set_description", {
        MenuLabel = "Set Description",
        Order     = 2,
        MenuIcon  = "icon16/note.png",

        Filter = function(self, ent, ply)
            return IsValid(ent)
               and ent:GetClass() == "ix_inspectable_prop"
               and ply:IsAdmin()
        end,

        Action = function(self, ent)
            Derma_StringRequest(
                "Set Description", "Enter new description:",
                ent:GetNetVar("desc", ""),
                function(input)
                    net.Start("ixInspectablePropUpdate")
                        net.WriteEntity(ent)
                        net.WriteString("desc")
                        net.WriteString(input)
                    net.SendToServer()
                end
            )
        end
    })

    properties.Add("ix_set_inspectlabel", {
        MenuLabel = "Set Inspect Label",
        Order     = 3,
        MenuIcon  = "icon16/magnifier.png",

        Filter = function(self, ent, ply)
            return IsValid(ent)
               and ent:GetClass() == "ix_inspectable_prop"
               and ply:IsAdmin()
        end,

        Action = function(self, ent)
            Derma_StringRequest(
                "Set Inspect Label", "Enter new menu label:",
                ent:GetNetVar("inspectLabel", ""),
                function(input)
                    net.Start("ixInspectablePropUpdate")
                        net.WriteEntity(ent)
                        net.WriteString("inspectLabel")
                        net.WriteString(input)
                    net.SendToServer()
                end
            )
        end
    })

    properties.Add("ix_set_inspectmsg", {
        MenuLabel = "Set Inspect Message",
        Order     = 4,
        MenuIcon  = "icon16/comment.png",

        Filter = function(self, ent, ply)
            return IsValid(ent)
               and ent:GetClass() == "ix_inspectable_prop"
               and ply:IsAdmin()
        end,

        Action = function(self, ent)
            Derma_StringRequest(
                "Set Inspect Message", "Enter new chat message:",
                ent:GetNetVar("inspectMsg", ""),
                function(input)
                    net.Start("ixInspectablePropUpdate")
                        net.WriteEntity(ent)
                        net.WriteString("inspectMsg")
                        net.WriteString(input)
                    net.SendToServer()
                end
            )
        end
    })

    properties.Add("ix_set_model", {
        MenuLabel = "Set Model",
        Order     = 5,
        MenuIcon  = "icon16/brick.png",

        Filter = function(self, ent, ply)
            return IsValid(ent)
               and ent:GetClass() == "ix_inspectable_prop"
               and ply:IsAdmin()
        end,

        Action = function(self, ent)
            Derma_StringRequest(
                "Set Model", "Enter model path:",
                ent:GetNetVar("model", ""),
                function(input)
                    net.Start("ixInspectablePropUpdate")
                        net.WriteEntity(ent)
                        net.WriteString("model")
                        net.WriteString(input)
                    net.SendToServer()
                end
            )
        end
    })

properties.Add("ix_toggle_visibility", {
    MenuLabel = "Toggle Visibility",
    Order     = 6,
    MenuIcon  = "icon16/contrast.png",

    Filter = function(self, ent, ply)
        return IsValid(ent)
           and ent:GetClass() == "ix_inspectable_prop"
           and ply:IsAdmin()
    end,

    Action = function(self, ent)
        local currentColor = ent:GetColor()
        local isInvisible = currentColor.a == 0

        if isInvisible then
            ent:SetColor(Color(255, 255, 255, 255))
            ent:SetRenderMode(RENDERMODE_NORMAL)
        else
            ent:SetColor(Color(255, 255, 255, 0))
            ent:SetRenderMode(RENDERMODE_TRANSALPHA)
        end
    end
})

-- Register the entity
scripted_ents.Register(ENT, "ix_inspectable_prop")
