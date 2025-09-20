ITEM.name = "Pair of Dice"
ITEM.description = "Two six-sided dice, perfect for games of chance."
ITEM.model = "models/props_lab/box01a.mdl"
ITEM.category = "Clutter"
ITEM.width = 1
ITEM.height = 1

ITEM.functions.Roll = {
    OnRun = function(item)
        local client = item.player
        if not IsValid(client) then return false end

        local a, b = math.random(6), math.random(6)
        client:ConCommand("say /me rolls two dice and they land on " .. a .. " and " .. b .. ".")
        return false
    end
}
