local Schema = Schema

NEED = {}
NEED.name = "Hunger"
NEED.decayValue = 0.2
NEED.decayRate = 2
NEED.color = Color(240, 200, 40)
NEED.barPriority = 4
NEED.icon = "ixgui/molecule.png"
NEED.whitelist = true

-- Effect when hunger reaches zero
function NEED:DepletionEffect(client, character)
    client:ChatPrint("You are starving!")
    -- Apply any negative effects here, e.g. reduce health
end

Schema:RegisterNeed(NEED)