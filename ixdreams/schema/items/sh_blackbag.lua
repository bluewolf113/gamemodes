ITEM.name = "Self-Bag (Debug)"
ITEM.description = "Debug bag that attaches a watermelon to your head and provides a debug overlay."
ITEM.category = "Outfit"
ITEM.model = "models/props_junk/watermelon01.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.outfitCategory = "head"
ITEM.uniqueID = "selfbag"
ITEM.noBusiness = true
ITEM.debugMaterial = "models/debug/debugwhite"
ITEM.pacData = {[1] = {
    ["children"] = {
        [1] = {
            ["children"] = {
            },
            ["self"] = {
                ["Skin"] = 13,
                ["Invert"] = false,
                ["LightBlend"] = 1,
                ["CellShade"] = 0,
                ["OwnerName"] = "self",
                ["AimPartName"] = "",
                ["IgnoreZ"] = false,
                ["AimPartUID"] = "",
                ["Passes"] = 1,
                ["Name"] = "",
                ["NoTextureFiltering"] = false,
                ["DoubleFace"] = false,
                ["PositionOffset"] = Vector(0, 0, 0),
                ["IsDisturbing"] = false,
                ["Fullbright"] = false,
                ["EyeAngles"] = false,
                ["DrawOrder"] = 0,
                ["TintColor"] = Vector(0, 0, 0),
                ["UniqueID"] = "1868347450",
                ["Translucent"] = false,
                ["LodOverride"] = -1,
                ["BlurSpacing"] = 0,
                ["Alpha"] = 1,
                ["Material"] = "",
                ["UseWeaponColor"] = false,
                ["UsePlayerColor"] = false,
                ["UseLegacyScale"] = false,
                ["Bone"] = "eyes",
                ["Color"] = Vector(255, 255, 255),
                ["Brightness"] = 1,
                ["BoneMerge"] = false,
                ["BlurLength"] = 0,
                ["Position"] = Vector(-3.527, -0.15, -1.935),
                ["AngleOffset"] = Angle(0, 0, 0),
                ["AlternativeScaling"] = false,
                ["Hide"] = false,
                ["OwnerEntity"] = false,
                ["Scale"] = Vector(1, 1, 1),
                ["ClassName"] = "model",
                ["EditorExpand"] = false,
                ["Size"] = 1,
                ["ModelFallback"] = "",
                ["Angles"] = Angle(0, 0, 0),
                ["TextureFilter"] = 3,
                ["Model"] = "models/sal/halloween/bag.mdl",
                ["BlendMode"] = "",
            },
        },
    },
    ["self"] = {
        ["DrawOrder"] = 0,
        ["UniqueID"] = "197916561",
        ["AimPartUID"] = "",
        ["Hide"] = false,
        ["Duplicate"] = false,
        ["ClassName"] = "group",
        ["OwnerName"] = "self",
        ["IsDisturbing"] = false,
        ["Name"] = "my outfit",
        ["EditorExpand"] = true,
    },
},
}

-- Used client-side to draw overlay while active
if CLIENT then
    hook.Add("HUDPaint", "ixDebugBagOverlay", function()
        local client = LocalPlayer()
        if client:GetNWBool("debugBagEquipped", false) then
            draw.RoundedBox(0, 0, 0, ScrW(), ScrH(), Color(100, 150, 250, 100))
            draw.SimpleText("DEBUG: Self-Bag Active", "DermaLarge", ScrW() * 0.5, ScrH() * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end)
end

-- Equip behavior
function ITEM:OnEquipped()
    local client = self.player
    if CLIENT or not IsValid(client) then return end

    client:SetNWBool("debugBagEquipped", true)

    if IsValid(client.debugBagEntity) then
        client.debugBagEntity:Remove()
    end

    local ent = ents.Create("prop_dynamic")
    if IsValid(ent) then
        ent:SetModel(self.model)
        ent:SetMaterial(self.debugMaterial or "")
        ent:SetOwner(client)
        ent:SetParent(client)
        ent:Fire("SetParentAttachmentMaintainOffset", "eyes")
        ent:SetMoveType(MOVETYPE_NONE)
        ent:Spawn()

        client.debugBagEntity = ent
    end
end

-- Unequip behavior
function ITEM:OnUnequipped()
    local client = self.player
    if CLIENT or not IsValid(client) then return end

    client:SetNWBool("debugBagEquipped", false)

    if IsValid(client.debugBagEntity) then
        client.debugBagEntity:Remove()
        client.debugBagEntity = nil
    end
end

-- Drop hook cleanup
ITEM:Hook("drop", function(item)
    if item:GetData("equip") then
        item:SetData("equip", false)
        item:OnUnequipped()
    end
end)

-- Equip function
ITEM.functions.Equip = {
    name = "Equip",
    icon = "icon16/eye.png",
    OnRun = function(item)
        local client = item.player
        local char = client:GetCharacter()

        item:SetData("equip", true)
        item:OnEquipped()
        return false
    end,
    OnCanRun = function(item)
        local client = item.player
        return IsValid(client) and !item:GetData("equip") and item.invID == client:GetCharacter():GetInventory():GetID()
    end
}

-- Unequip function
ITEM.functions.Unequip = {
    name = "Unequip",
    icon = "icon16/delete.png",
    OnRun = function(item)
        local client = item.player

        item:SetData("equip", false)
        item:OnUnequipped()
        return false
    end,
    OnCanRun = function(item)
        local client = item.player
        return IsValid(client) and item:GetData("equip") and item.invID == client:GetCharacter():GetInventory():GetID()
    end
}

-- Block transferring while active
function ITEM:CanTransfer(_, newInv)
    return not newInv or not self:GetData("equip")
end

-- Clean removal
function ITEM:OnRemoved()
    if self:GetData("equip") then
        self.player = self:GetOwner()
        self:SetData("equip", false)
        self:OnUnequipped()
        self.player = nil
    end
end