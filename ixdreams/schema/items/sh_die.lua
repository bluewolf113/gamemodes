ITEM.name = "Die"
ITEM.description = "A small six-sided die, perfect for games of chance."
ITEM.model = "models/props_lab/box01a.mdl"
ITEM.category = "Clutter"
ITEM.width = 1
ITEM.height = 1

ITEM.functions.Roll = {
    OnRun = function(item)
        local client = item.player
        if not IsValid(client) then return false end

        client:ConCommand("say /me rolls a die and it lands on " .. math.random(6) .. ".")
        return false
    end
}
