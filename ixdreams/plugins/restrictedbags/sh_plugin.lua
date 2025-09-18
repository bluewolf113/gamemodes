local PLUGIN = PLUGIN

PLUGIN.name        = "Restricted Bags (Optimized)"
PLUGIN.description = "Enforces item restrictions on bag inventories, with minimal overhead."
PLUGIN.author      = "Blue, updated by Copilot"

-- Pre-cache all bag definitions on plugin initialize
function PLUGIN:Initialize()
    -- bagDefs[b agID] = allowedItemsTable
    self.bagDefs = {}

    for id, item in pairs(ix.item.list) do
        if item.allowedItems then
            self.bagDefs[id] = item.allowedItems
        end
    end
end

-- Ensure inv.vars.allowedItems is set if this inventory belongs to a bag
local function ensureAllowed(inv)
    local vars = inv.vars
    if not vars or not vars.isBag or vars.allowedItems then
        return
    end

    vars.allowedItems = PLUGIN.bagDefs[vars.isBag]
end

function PLUGIN:CanTransferItem(item, fromInv, toInv)
    if not item or not fromInv or not toInv then
        return
    end

    -- Populate allowedItems lazily only once per inventory
    ensureAllowed(fromInv)
    ensureAllowed(toInv)

    local uid = item.uniqueID
    local owner = item:GetOwner()

    -- Trying to put into a restricted bag?
    local toAllowed = toInv.vars.allowedItems
    if toAllowed and not toAllowed[uid] then
        owner:Notify("You cannot store that item in this bag.")
        return false
    end
end
