local Schema = Schema

-- controls whether certain attributes can increase or not

NEED = {}
NEED.name = "Nutrition"
NEED.decayValue = 0.01
NEED.decayRate = 2
NEED.color = Color(255, 255, 255)
NEED.bNoBar = true
NEED.icon = "ixgui/spoon.png"
NEED.whitelist = true

-- Effect when hunger reaches zero
function NEED:DepletionEffect(client, character)

end

Schema:RegisterNeed(NEED)