AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Custom Entity"
ENT.Category = "Helix"
ENT.Author = "Nicholas"
ENT.Spawnable = true
ENT.AdminOnly = false

function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "EntityName") 
    self:NetworkVar("String", 1, "EntityDesc")   
    self:NetworkVar("String", 2, "ExtraDesc")    
    self:NetworkVar("Bool", 3, "HasInteracted")  
end

function ENT:Initialize()
    if SERVER then
        self:SetModel("models/props_c17/FurnitureWashingmachine001a.mdl")
        self:SetNWString("EntityName", "Unknown Entity")
        self:SetNWString("EntityDesc", "No details available.")
        self:SetNWString("ExtraDesc", "")
        self:SetNWBool("HasInteracted", false)

        self.extraDescriptions = {
            "There's a strange humming noise coming from inside.",
            "The surface feels oddly warm to the touch.",
            "You spot faint scratches—someone else has been here before.",
            "It smells faintly of ozone.",
            "A slight vibration pulses through it."
        }

        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)

        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:Wake()
        end
    end
end

function ENT:Use(activator)
    if SERVER and not self:GetNWBool("HasInteracted", false) then
        local randomExtra = self.extraDescriptions[math.random(#self.extraDescriptions)]
        self:SetNWString("ExtraDesc", randomExtra)
        self:SetNWBool("HasInteracted", true)

        -- Force tooltip reset by manipulating trace logic for one frame
        net.Start("ixForceTooltipReset")
            net.WriteEntity(self)
        net.Send(activator)
    end
end

if CLIENT then
    function ENT:OnPopulateEntityInfo(container)
        local ent = self  

        -- Create and populate name row
        local nameRow = container:AddRow("name")
        nameRow:SetImportant()
        nameRow:SetText(ent:GetNWString("EntityName", "Unknown Entity"))
        nameRow:SizeToContents()

        -- Determine what to show for extra row
        local extraText = ent:GetNWBool("HasInteracted", false) and ent:GetNWString("ExtraDesc", "") or "[E]"

        local extraRow = container:AddRow("extra")
        extraRow:SetText(extraText)
        extraRow:SetTextColor(extraText == "[E]" and Color(150,150,150) or Color(255,255,255))
        extraRow:SizeToContents()

        container:SizeToContents()
    end

    net.Receive("ixForceTooltipReset", function()
        local ent = net.ReadEntity()
        if not IsValid(ent) then return end

        local client = LocalPlayer()
        if not IsValid(client) then return end

        -- Store original trace distance
        local originalTraceEndPos = client:GetShootPos() + client:GetAimVector() * 160

        -- Temporarily set trace distance to 0 to force tooltip disappearance
        local traceData = {}
        traceData.start = client:GetShootPos()
        traceData.endpos = traceData.start + client:GetAimVector() * 0 -- Set distance to 0
        traceData.filter = client
        traceData.mask = MASK_SHOT_HULL

        -- Run trace immediately to clear entity focus
        util.TraceHull(traceData)

        -- Restore normal trace distance after one frame
        timer.Simple(0.01, function()
            traceData.endpos = originalTraceEndPos -- Reset back to default distance
            util.TraceHull(traceData) -- Restore detection
        end)
    end)
end

properties.Add("set_entity_name", {
    MenuLabel = "Set Entity Name",
    Order = 1,
    MenuIcon = "icon16/tag_blue_edit.png",
    Filter = function(self, ent, ply)
        return IsValid(ent) and ent:GetClass() == "ix_interactor" and ply:IsAdmin()
    end,
    Action = function(self, ent)
        Derma_StringRequest("Entity Name", "Enter a new name for this entity:", 
            ent:GetNWString("EntityName", "Unknown Entity"), 
            function(text)
                net.Start("ixSetEntityName")
                    net.WriteEntity(ent)
                    net.WriteString(text)
                net.SendToServer()
            end)
    end
})

properties.Add("list_extra_descs", {
    MenuLabel = "List Extra Descriptions",
    Order = 3,
    MenuIcon = "icon16/page_white_text.png",
    Filter = function(self, ent, ply)
        return IsValid(ent) and ent:GetClass() == "ix_interactor" and ply:IsAdmin()
    end,
    Action = function(self, ent)
        local descriptions = table.concat(ent.extraDescriptions, "\n")
        chat.AddText(Color(255,200,0), "[Extra Descriptions] ", Color(255,255,255), descriptions)
    end
})

if SERVER then
    util.AddNetworkString("ixSetEntityName")
    util.AddNetworkString("ixSetEntityDesc")
    util.AddNetworkString("ixForceTooltipReset")

    net.Receive("ixSetEntityName", function(len, ply)
        local ent = net.ReadEntity()
        local name = net.ReadString()
        if IsValid(ent) then
            ent:SetNWString("EntityName", name)
        end
    end)

    net.Receive("ixSetEntityDesc", function(len, ply)
        local ent = net.ReadEntity()
        local desc = net.ReadString()
        if IsValid(ent) then
            ent:SetNWString("EntityDesc", desc)
        end
    end)
end
