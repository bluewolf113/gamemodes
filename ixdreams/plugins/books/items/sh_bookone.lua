ITEM.name = "'Book 1'"
ITEM.model = "models/illusion/eftcontainers/laptop.mdl"
ITEM.category = "Literature"
ITEM.width = 1
ITEM.height = 2
ITEM.description = "A derelict relic of a bygone era..."
ITEM.price = 0

ITEM.pages = {
    [1] = "— SO THAT WE OF THE VETUS MYSTERY MIGHT LEARN FROM THE TENETS OF THE PANTHEON.",
    [2] = "IN THEIR FINAL STAND THEY HAVE PASSED THE MANTLE OF DUTY ON TO US.",
    [3] = "COME UNDER OUR BANNER, THOSE FAITHFUL TO THE FUTURE OF OUR SPECIES.",
    [4] = "READ ON AND KNOW OF THE FALLEN GLORY OF THE PANTHEON. READ ON AND BE SAVED."
}

ITEM.functions.use = {
    name = "Open",
    icon = "icon16/pencil.png",
    OnRun = function(item)
        local client = item.player
        local id = item:GetID()

        if id then
            local cleanPages = {}
            for k, v in pairs(item.pages or {}) do
                cleanPages[k] = tostring(v)
            end

            netstream.Start(client, "receiveBook", id, cleanPages, item.name)
        end

        return false
    end
}

ITEM:PostHook("OnItemTransferred", function(self, oldInventory, newInventory)
    local receiver = self.player

    if IsValid(receiver) then
        receiver:EmitSound("items/paper_pickup.wav", 60)
    end
end)