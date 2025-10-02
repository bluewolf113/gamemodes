ITEM.name = "Vort Shackle"
ITEM.model = Model("models/props_junk/watermelon01.mdl")
ITEM.description = "test."
ITEM.category = "Equipment"

ITEM.functions.Shackle = {
    name = "Shackle",
    icon = "icon16/link.png",

    OnRun = function(itemTable)
        local client = itemTable.player
        local trace = util.TraceLine({
            start = client:GetShootPos(),
            endpos = client:GetShootPos() + client:GetAimVector() * 96,
            filter = client
        })

        local target = trace.Entity
        if not (IsValid(target) and target:IsPlayer()) then
            client:NotifyLocalized("plyNotValid")
            return false
        end

        local character = target:GetCharacter()
        if not character then return false end

        if character:GetFaction() ~= FACTION_VORTIGAUNT then
            client:Notify("This can only be used on Vortigaunts.")
            return false
        end

        if character:GetClass() == CLASS_BIOTIC then
            client:Notify("Target is already shackled.")
            return false
        end

        itemTable.bBeingUsed = true
        client:SetAction("Shackling...", 5)

        client:DoStaredAction(target, function()
            character:SetClass(CLASS_BIOTIC)
            target:SetModel("models/vortigaunt_slave.mdl") -- Replace with your actual shackled model path
            target:Notify("You have been shackled.")
            local stripList = {
                ["ix_nightvision"] = true,
                ["ix_vortheal"]    = true,
                ["ix_vortbeam"]    = true
            }
            for _, wep in ipairs(target:GetWeapons()) do
                local class = wep:GetClass()
                if stripList[class] then
                    target:StripWeapon(class)
                end
            end
            itemTable:Remove()
        end, 5, function()
            client:SetAction()
            itemTable.bBeingUsed = false
        end)

        return false
    end,

    OnCanRun = function(itemTable)
        return not IsValid(itemTable.entity) and not itemTable.bBeingUsed
    end
}

function ITEM:CanTransfer(inventory, newInventory)
    return not self.bBeingUsed
end
