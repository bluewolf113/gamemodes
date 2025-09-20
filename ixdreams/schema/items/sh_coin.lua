ITEM.name = "Coin"
ITEM.description = "A small metal coin, perfect for flipping."
ITEM.model = "models/props_lab/box01a.mdl"
ITEM.category = "Clutter"
ITEM.width = 1
ITEM.height = 1

ITEM.functions.Flip = {
    OnRun = function(item)
        local client = item.player
        if not IsValid(client) then return false end

        client:ConCommand("say /me flips a coin and it lands on " .. (math.random(2) == 1 and "heads" or "tails") .. ".")
        return false
    end
}
