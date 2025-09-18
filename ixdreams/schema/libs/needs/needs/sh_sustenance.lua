local Schema = Schema

-- replaces hunger/thirst for transhumans

NEED = {}
NEED.name = "Sustenance"
NEED.decayValue = 0.2
NEED.decayRate = 2
NEED.color = Color(100, 200, 160)
NEED.barPriority = 7
NEED.icon = "ixgui/molecule.png"
NEED.whitelist = false

-- Effect when hunger reaches zero
function NEED:DepletionEffect(client, character)
    client:ChatPrint("You are starving!")
    -- Apply any negative effects here, e.g. reduce health
end

Schema:RegisterNeed(NEED)