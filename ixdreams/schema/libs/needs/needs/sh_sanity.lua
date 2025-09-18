local Schema = Schema

-- toggled by transhuman brain surgery

NEED = {}
NEED.name = "Sanity"
NEED.decayValue = 0.2
NEED.decayRate = 2
NEED.color = Color(160, 20, 100)
NEED.barPriority = 7
NEED.icon = "ixgui/brain-stem.png"
NEED.whitelist = false

-- Effect when hunger reaches zero
function NEED:DepletionEffect(client, character)
    client:ChatPrint("You are starving!")
    -- Apply any negative effects here, e.g. reduce health
end

Schema:RegisterNeed(NEED)