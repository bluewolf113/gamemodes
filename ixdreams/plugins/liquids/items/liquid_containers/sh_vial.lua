
ITEM.name = "Vial"
ITEM.description = "Vial"
ITEM.model = "models/props_lab/jar01a.mdl"
ITEM.width	= 1
ITEM.height	= 2
ITEM.capacity = 40

ITEM.functions.Venom = {
    name = "Extract Headcrab Venom",
    icon = "ixgui/molecule.png",

    OnRun = function(item)
        local client = item.player

        local data = {}
        data.start = client:GetShootPos()
        data.endpos = data.start + client:GetAimVector() * ix.config.Get("lookRange", 160)
        data.filter = function(ent)
            local model = ent:GetModel() or ""
            return string.find(model, "models/headcrabblack.mdl", 1, true) ~= nil
        end

        local trace = util.TraceLine(data)
        local headcrabEnt = trace.Entity

        if not IsValid(headcrabEnt) then return false end

        item:SetLiquid("poisonheadcrab")
        item:SetVolume(item.capacity)
        client:EmitSound("ambient/levels/labs/teleport_preblast.wav", 60)

        return false
    end,

    OnCanRun = function(item)
        if item:GetVolume() == item.capacity then
            return false
        end

        if item:GetLiquid() and item:GetLiquid() ~= "poisonheadcrab" then
            return false
        end

        local client = item.player
        local data = {}
        data.start = client:GetShootPos()
        data.endpos = data.start + client:GetAimVector() * ix.config.Get("lookRange", 160)
        data.filter = function(ent)
            local model = ent:GetModel() or ""
            return string.find(model, "models/headcrabblack.mdl", 1, true) ~= nil
        end

        local trace = util.TraceLine(data)
        return IsValid(trace.Entity)
    end
}

ITEM.functions.combine = {
    OnRun = function(container, data)
        local client = container.player
        local liquidSource = ix.item.instances[data[1]]

        if liquidSource and liquidSource:GetLiquid() == "poisonheadcrab" then
            liquidSource:SetVolume(0)
            container:SetData("isPoisoned", true)
            client:Notify(string.format("You contaminated %s with headcrab venom.", container:GetName()))
        end

        return false
    end,

    OnCanRun = function(container, data)
        local liquidSource = ix.item.instances[data[1]]
        return liquidSource and liquidSource:GetLiquid() == "poisonheadcrab"
    end
}
