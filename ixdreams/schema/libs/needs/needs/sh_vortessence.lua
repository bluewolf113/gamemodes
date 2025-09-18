local Schema = Schema

NEED = {}
NEED.name = "Vortessence"
NEED.decayValue = -5
NEED.decayRate = 2
NEED.color = Color(40, 200, 0)
NEED.barPriority = 6
NEED.icon = "ixgui/portal.png"
NEED.whitelist = "Vortigaunt"

-- Effect when hunger reaches zero
function NEED:DepletionEffect(client, character)
    client:ChatPrint("You are starving!")
    -- Apply any negative effects here, e.g. reduce health
end

Schema:RegisterNeed(NEED)