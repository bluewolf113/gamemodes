--[[
    © 2020 TERRANOVA do not share, re-distribute or modify
    without permission of its author.
--]]

local PLUGIN = PLUGIN
local PANEL = {}

-- Called when the panel is first initialized.
function PANEL:Init()
    if (IsValid(ix.gui.menu)) then
        ix.gui.menu:Remove()
    end

    self:SetBackgroundBlur(true)
    self:ShowCloseButton(false)
    self:Center()
    self:MakePopup()
    self:SetTitle("")
    self:SetAlpha(0)

    -- Replace ixNewButton with ix.button to ensure compatibility
    self.exitButton = self:Add("ix.button")
    self.exitButton:SetFont("ixSmallFont")
    self.exitButton:SetSize(16, 16)
    self.exitButton:SetPos(480, 16)
    self.exitButton:SetText("X")

    function self.exitButton:DoClick()
        ix.gui.record:SendToServer(VIEWDATA_UPDATEVAR, {
            var = "note",
            info = ix.gui.record.note.textEntry:GetText()
        })
        ix.gui.record:Remove()
    end
end

function PANEL:Paint() 
    surface.SetMaterial(ix.util.GetMaterial("materials/terranova/ui/viewdata/background.png"))
    surface.SetDrawColor(255, 255, 255, 255)
    surface.DrawTexturedRect(0, 0, 512, 512)

    surface.SetMaterial(ix.util.GetMaterial("materials/terranova/ui/viewdata/combineoverlay.png"))
    surface.SetDrawColor(255, 255, 255, 150)
    surface.DrawTexturedRect(0, 0, 512, 512)
end

-- Called each frame of the panel being open.
function PANEL:Think()
    local scrW, scrH = ScrW(), ScrH()

    self:SetSize(512, 512)
    self:SetPos((scrW / 2) - (self:GetWide() / 2), (scrH / 2) - (self:GetTall() / 2))
end

function PANEL:AddStage(text, panelType)
    local panel = self:Add(panelType or "DPanel")
    panel:Dock(FILL)
    panel:DockMargin(16, 0, 16, 16)
    panel:SetVisible(false)

    self.stages = self.stages or {}
    self.stages[text] = panel

    return panel
end

function PANEL:SetStage(text)
    if not self.stages[text] then return end

    for k, v in pairs(self.stages) do
        v:SetVisible(k == text)
    end
end

-- Called when the panel is receiving data and will start to build.
function PANEL:Build(target, cid, record)
    self.target = target
    self.character = target:GetCharacter()
    self.cidValue = cid
    self.recordTable = record

    self.content = self:AddStage("Home")
    self.content:SetDrawBackground(false)
    self.content:Add(self:BuildLabel("Civil Protection Datapad", true))
    
    self:BuildCID()

    self.record = self:AddStage("Record", "ixCombineViewDataRecord")
    self.note = self:AddStage("Note", "ixCombineViewDataViewNote")
    self.unitrecord = self:AddStage("UnitRecord", "ixCombineViewDataUnitRecord")
    self.vars = self:AddStage("EditData", "ixCombineViewDataEditData")

    self:SetStage("Home")
    self:AlphaTo(255, 0.5)

    self:BuildButtons()
end

function PANEL:GetRecord()
    return self.recordTable or {
        rows = {},
        vars = {
            ["note"] = PLUGIN.defaultNote
        }
    }
end

function PANEL:BuildCID()
    self.cid = self.content:Add("DPanel")
    self.cid:Dock(TOP)
    self.cid:DockMargin(0, 8, 0, 8)
    self.cid:SetTall(196)
    self.cid:SetDrawBackground(false)

    self.modelBackground = self.cid:Add(self:DrawCharacter())

    self.rightDock = self.cid:Add("DPanel")
    self.rightDock:Dock(FILL)
    self.rightDock:DockMargin(8, 16, 16, 16)
    self.rightDock:SetDrawBackground(false)

    self.name = self.rightDock:Add(self:BuildLabel("Name: " .. (self.character:GetName() or "Error"), false, 4))
    self.cid = self.rightDock:Add(self:BuildLabel("Citizen ID: #" .. (self.cidValue or "ERROR"), false, 4))
    self.points = self.rightDock:Add(self:BuildLabel("Total Points: ERROR", false, 4))
end

function PANEL:BuildButtons()
    self.buttonLayout = self.content:Add("DIconLayout")
    self.buttonLayout:Dock(FILL)
    self.buttonLayout:DockMargin(0, 4, 0, 4)
    self.buttonLayout:SetSpaceX(4)
    self.buttonLayout:SetSpaceY(4)
    self.buttonLayout:SetStretchWidth(true)
    self.buttonLayout:SetStretchHeight(true)
    self.buttonLayout:InvalidateLayout(true)

    self.buttonLayout:Add(self:AddStageButton("View Record", "Record"))
    self.buttonLayout:Add(self:AddStageButton("View Note", "Note"))

    local unitRecord = self.buttonLayout:Add(self:AddStageButton("View Unit Record\n(Unavailable)", "UnitRecord"))
    local editData = self.buttonLayout:Add(self:AddStageButton("Edit Data\n(Unavailable)", "EditData"))

    unitRecord:SetEnabled(false)
    editData:SetEnabled(false)
end

function PANEL:SetLoyaltyPoints(record)
    local count = 0

    if IsValid(record) then
        for _, v in pairs(record:GetLines()) do
            count = count + (v:GetValue(3) or 0)
        end
    end

    self.points:SetText("Loyalty Points: " .. count)
end

function PANEL:DrawCharacter(small)
    local modelBackground = vgui.Create("DPanel")
    modelBackground:Dock(LEFT)

    if not small then
        modelBackground:SetSize(180, 180)
        modelBackground:DockMargin(16, 16, 16, 16)
    end
    
    function modelBackground:Paint(w, h)
        surface.SetDrawColor(25, 25, 25, 225)
        surface.DrawRect(0, 0, w, h)

        surface.SetMaterial(ix.util.GetMaterial("materials/terranova/ui/viewdata/datamugshot.png"))
        surface.SetDrawColor(255, 255, 255, 225)
        surface.DrawTexturedRect(0, 0, w, h)

        surface.SetDrawColor(90, 90, 90, 255)
        surface.DrawOutlinedRect(0, 0, w, h)
    end
    
    local model = modelBackground:Add("DModelPanel")
    model:Dock(FILL)

    if not small then
        model:DockMargin(2, 2, 2, 2)
    end

    model:SetModel(self.target:GetModel())
    model.Entity:SetSkin(self.character:GetData("skin", 0))

    for k, v in pairs(self.character:GetData("groups", {})) do
        model.Entity:SetBodygroup(k, v)
    end

    function model:LayoutEntity(Entity) return end

    local eyepos = model.Entity:GetBonePosition(model.Entity:LookupBone("ValveBiped.Bip01_Head1"))
    eyepos:Add(Vector(0, 0, 2)) -- Move up slightly
    model:SetLookAt(eyepos)
    model:SetCamPos(eyepos - Vector(-12, 4, 0)) -- Move cam in front of eyes
    model.Entity:SetEyeTarget(eyepos - Vector(-12, 0, 0))
    
    return modelBackground
end

vgui.Register("ixCombineViewData", PANEL, "DFrame")
