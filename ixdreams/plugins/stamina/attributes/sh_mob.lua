ATTRIBUTE.name = "Mobility"
ATTRIBUTE.description = "Sometimes you might have to run from something. Not everybody moves fast."
ATTRIBUTE.icon = "ixgui/dodging.png"
ATTRIBUTE.category = "Physical"

function ATTRIBUTE:OnSetup(client, value)
	local newValue = ix.config.Get("runSpeed") + value
	client:SetRunSpeed(ix.config.Get("runSpeed") + value)
end
