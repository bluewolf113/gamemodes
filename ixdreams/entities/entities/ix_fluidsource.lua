AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Fluid Source"
ENT.Category = "Helix"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.PhysgunDisable = false
-- ENT.bNoPersist = true

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "DisplayName")
	self:NetworkVar("String", 1, "Description")
    self:NetworkVar("String", 2, "Type")
    self:NetworkVar("String", 3, "VisibleModel")
	self:NetworkVar("Int", 4, "AmountLeft")
	self:NetworkVar("Int", 5, "AmountMax")
    self:NetworkVar("Bool", 6, "Point")
end

if SERVER then
    util.AddNetworkString("ixSetFluidSourceDisplayName")
    util.AddNetworkString("ixSetFluidSourceDescription")
    util.AddNetworkString("ixSetFluidSourceVisibleModel")
    util.AddNetworkString("ixSetFluidSourceType")
	util.AddNetworkString("ixSetFluidSourceAmountLeft")
    util.AddNetworkString("ixSetFluidSourcePoint")

    function ENT:Initialize()
		self:SetDisplayName("Spigot")
		self:SetDescription("An old spigot dripping dirty water.")
		self:SetVisibleModel("models/props_wasteland/prison_pipefaucet001a.mdl")
		self:SetAmountLeft(0)
		self:SetAmountMax(-1)
		self:SetType("water_polluted")
		
		self:SetModel(self:GetVisibleModel())
        self:SetSolid(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetUseType(SIMPLE_USE)

        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:Wake()
        end
    end

    function ENT:Use(activator, caller)
        -- Placeholder for use interaction
    end
	
	net.Receive("ixSetFluidSourceDisplayName", function(length, client)
        local entity = net.ReadEntity()
        local sDisplayName = net.ReadString()

        if IsValid(entity) and entity:GetClass() == "ix_fluidsource" then
            entity:SetDisplayName(sDisplayName)
        end
    end)
	
	net.Receive("ixSetFluidSourceDescription", function(length, client)
        local entity = net.ReadEntity()
        local sDescription = net.ReadString()

        if IsValid(entity) and entity:GetClass() == "ix_fluidsource" then
            entity:SetDescription(sDescription)
        end
    end)

    net.Receive("ixSetFluidSourceVisibleModel", function(length, client)
        local entity = net.ReadEntity()
        local model = net.ReadString()

        if IsValid(entity) and entity:GetClass() == "ix_fluidsource" and util.IsValidModel(model) then
            entity:SetVisibleModel(model)
			entity:SetModel(entity:GetVisibleModel())
            entity:SetMoveType(MOVETYPE_VPHYSICS)
            entity:PhysicsInit(SOLID_VPHYSICS)
            entity:SetSolid(SOLID_VPHYSICS)

            local phys = entity:GetPhysicsObject()
            if IsValid(phys) then
                phys:Wake()
            end
        end
    end)

    net.Receive("ixSetFluidSourceType", function(length, client)
        local entity = net.ReadEntity()
        local fluidType = net.ReadString()

        if IsValid(entity) and entity:GetClass() == "ix_fluidsource" then
            entity:SetType(fluidType)
        end
    end)

    net.Receive("ixSetFluidSourcePoint", function(length, client)
        local entity = net.ReadEntity()
        local Point = net.ReadBool()

        if IsValid(entity) and entity:GetClass() == "ix_fluidsource" then
            entity:SetPoint(Point)

            if Point then
                entity:SetModel("models/props_junk/watermelon01.mdl")
				entity:SetMoveType(MOVETYPE_VPHYSICS)
				entity:PhysicsInit(SOLID_VPHYSICS)
				entity:SetSolid(SOLID_VPHYSICS)
                entity:DrawShadow(false)
                entity:SetNoDraw(true)
            else
                entity:SetModel(entity:GetVisibleModel() or "models/props_c17/consolebox01a.mdl")
				entity:SetMoveType(MOVETYPE_VPHYSICS)
				entity:PhysicsInit(SOLID_VPHYSICS)
				entity:SetSolid(SOLID_VPHYSICS)
                entity:DrawShadow(true)
                entity:SetNoDraw(false)
            end
        end
    end)
	
	net.Receive("ixSetFluidSourceAmountLeft", function(length, client)
        local entity = net.ReadEntity()
		local amountMax = net.ReadInt(32)
        local amountLeft = net.ReadInt(32)

        if IsValid(entity) and entity:GetClass() == "ix_fluidsource" then
			entity:SetAmountMax(amountMax)
            entity:SetAmountLeft(amountLeft or 0)
        end
    end)
	
	net.Receive("ixSetFluidSourceAmountMax", function(length, client)
        local entity = net.ReadEntity()
        local amountMax = net.ReadInt(32)

        if IsValid(entity) and entity:GetClass() == "ix_fluidsource" then
            entity:SetAmountMax(amountMax)
        end
    end)
end

properties.Add("set_fluid_source_displayname", {
	MenuLabel = "Set Name",
	Order = 1,
	MenuIcon = "icon16/application_form_edit.png",

	Filter = function(self, ent, ply)
		if not IsValid(ent) or ent:GetClass() ~= "ix_fluidsource" then return false end
		if not ply:IsAdmin() then return false end
		return true
	end,

	Action = function(self, ent)
		Derma_StringRequest("Set Display Name", "Enter display name:", ent:GetDisplayName(), function(name)
		
			net.Start("ixSetFluidSourceDisplayName")
			net.WriteEntity(ent)
			net.WriteString(name)
			net.SendToServer()
		end)
	end
})

properties.Add("set_fluid_source_description", {
	MenuLabel = "Set Description",
	Order = 2,
	MenuIcon = "icon16/application_form_edit.png",

	Filter = function(self, ent, ply)
		if not IsValid(ent) or ent:GetClass() ~= "ix_fluidsource" then return false end
		if not ply:IsAdmin() then return false end
		return true
	end,

	Action = function(self, ent)
		Derma_StringRequest("Set Description", "Enter description:", ent:GetDescription(), function(description)

			net.Start("ixSetFluidSourceDescription")
			net.WriteEntity(ent)
			net.WriteString(description)
			net.SendToServer()
		end)
	end,
})

properties.Add("set_fluid_source_model", {
	MenuLabel = "Set Model",
	Order = 3,
	MenuIcon = "icon16/application_form_edit.png",

	Filter = function(self, ent, ply)
		if not IsValid(ent) or ent:GetClass() ~= "ix_fluidsource" then return false end
		if not ply:IsAdmin() then return false end
		return true
	end,

	Action = function(self, ent)
		Derma_StringRequest("Set Model", "Enter the model path:", ent:GetVisibleModel(), function(modelPath)
			net.Start("ixSetFluidSourceVisibleModel")
			net.WriteEntity(ent)
			net.WriteString(modelPath)
			net.SendToServer()
		end)
	end,
})

properties.Add("set_fluid_source_type", {
	MenuLabel = "Set Fluid Type",
	Order = 4,
	MenuIcon = "icon16/water.png",

	Filter = function(self, ent, ply)
		if not IsValid(ent) or ent:GetClass() ~= "ix_fluidsource" then return false end
		if not ply:IsAdmin() then return false end
		return true
	end,

	Action = function(self, ent)

	end,
	
	MenuOpen = function(self, option, ent, tr)

		local submenu = option:AddSubMenu()
		local ccTbl = ix.item.containerContents
		local w =  ScrW()
		local h = ScrH()
		local current = ent:GetType()
		
		for uniqueID, cc in pairs(ccTbl) do
			local option = submenu:AddOption(uniqueID, function()
				net.Start("ixSetFluidSourceType")
				net.WriteEntity(ent)
				net.WriteString(uniqueID)
				net.SendToServer()
			end)
			
			if current == uniqueID then
				option:SetChecked(true)
			end
		end
	end
})

properties.Add("set_fluid_source_point", {
	MenuLabel = "Set Point",
	Order = 5,
	MenuIcon = "icon16/brick.png",

	Filter = function(self, ent, ply)
		if not IsValid(ent) or ent:GetClass() ~= "ix_fluidsource" then return false end
		if not ply:IsAdmin() then return false end
		return true
	end,

	Action = function(self, ent)
	
	end,
	
	MenuOpen = function(self, option, ent, tr)

	local submenu = option:AddSubMenu()
	local trueOption = submenu:AddOption("True", function()                 
		net.Start("ixSetFluidSourcePoint")
			net.WriteEntity(ent)
			net.WriteBool(true)
		net.SendToServer()
		end)
		
	local falseOption = submenu:AddOption("False",function()                 
		net.Start("ixSetFluidSourcePoint")
			net.WriteEntity(ent)
			net.WriteBool(false)
		net.SendToServer()
		end)

	-- Set the current selection as checked
	local current = ent:GetPoint()
	if (current) then
		trueOption:SetChecked(true)
	else
		falseOption:SetChecked(true)
	end
end
})

properties.Add("set_fluid_source_amount", {
    MenuLabel = "Set Amount",
    Order = 5,
    MenuIcon = "icon16/brick.png",

    Filter = function(self, ent, ply)
        if not IsValid(ent) or ent:GetClass() ~= "ix_fluidsource" then return false end
        if not ply:IsAdmin() then return false end
        return true
    end,

    Action = function(self, ent)
        -- This remains unused unless you want to directly trigger something
    end,

    MenuOpen = function(self, option, ent, tr)
        local submenu = option:AddSubMenu()
        local inputOption = submenu:AddOption("Set Values", function()
            local frame = vgui.Create("DFrame")
            frame:SetTitle("Set Fluid Values")
            frame:SetSize(300, 160)
            frame:Center()
            frame:MakePopup()

            local maxLabel = vgui.Create("DLabel", frame)
            maxLabel:SetText("Amount Max (-1 for infinite):")
            maxLabel:SizeToContents()
            maxLabel:SetPos(15, 35)

            local maxEntry = vgui.Create("DTextEntry", frame)
            maxEntry:SetPos(100, 30)
            maxEntry:SetSize(180, 20)
            maxEntry:SetNumeric(true)

            local leftLabel = vgui.Create("DLabel", frame)
            leftLabel:SetText("Amount Left:")
            leftLabel:SizeToContents()
            leftLabel:SetPos(15, 65)

            local leftEntry = vgui.Create("DTextEntry", frame)
            leftEntry:SetPos(100, 60)
            leftEntry:SetSize(180, 20)
            leftEntry:SetNumeric(true)

            local submit = vgui.Create("DButton", frame)
            submit:SetText("Submit")
            submit:SetPos(100, 100)
            submit:SetSize(90, 25)
            submit.DoClick = function()
                local max = tonumber(maxEntry:GetValue()) or 0
                local left = tonumber(leftEntry:GetValue()) or 0

                net.Start("ixSetFluidSourcePoint")
                    net.WriteEntity(ent)
                    net.WriteBool(true)
                    net.WriteFloat(max)

                    if max >= 0 then
                        net.WriteFloat(left)
                    end
                net.SendToServer()

                frame:Close()
            end
        end)

        -- Existing True/False options (optional if using value input now)
        local current = ent:GetPoint()
        if current then
            inputOption:SetChecked(true)
        end
    end
})

if CLIENT then
	
	ENT.PopulateEntityInfo = true
	
	function ENT:OnPopulateEntityInfo(container)
		local bNoDisplayInfo = self:GetPoint()
		
		if not bNoDisplayInfo then
			local name = container:AddRow("name")
			name:SetImportant()
			name:SetText(self:GetDisplayName())
			name:SizeToContents()

			local descriptionText = self:GetDescription()

			if (descriptionText != "") then
				local description = container:AddRow("description")
				description:SetText(self:GetDescription())
				description:SizeToContents()
			end
		end
	end

	function ENT:Draw()
		local player = LocalPlayer()
		
		if not self:GetPoint() or player:GetMoveType() == MOVETYPE_NOCLIP then
			self:DrawModel()
		end
	end

end

