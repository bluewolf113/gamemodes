local Schema = Schema

NEED = {}
NEED.name = "Thirst"
NEED.decayValue = 0.4 -- Decay rate per minute
NEED.decayRate = 1 -- Decay rate per minute
NEED.color = Color(120, 120, 255) -- Blue
NEED.barPriority = 5
NEED.icon = "ixgui/drop.png"
NEED.whitelist = true

-- Effect when thirst reaches zero
function NEED:DepletionEffect(client, character)
    client:ChatPrint("You are suffering from dehydration!")
    -- Apply any negative effects here, e.g. reduce health
end

Schema:RegisterNeed(NEED)