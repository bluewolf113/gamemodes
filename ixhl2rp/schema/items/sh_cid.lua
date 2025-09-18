
ITEM.name = "Citizen ID"
ITEM.model = Model("models/gibs/metal_gib4.mdl")
ITEM.description = "A citizen identification card with ID #%s, assigned to %s."
ITEM.isExamineable = true

ITEM.attributeDescriptions = {
    intelligence = {
        "Intelligence: You analyze the barcode—it seems outdated.",
        "Intelligence: The ID contains a serial number from an old database."
    },
    shivers = {
        "Shivers: The ID feels strangely cold, despite the room temperature.",
        "Shivers: A faint, unsettling static hum emits from its material."
    }
}

ITEM.neutralDescriptions = {
    "A worn-out citizen ID with faded print.",
    "The edges are slightly frayed, possibly from heavy use."
}

function ITEM:GetDescription()
	return string.format(self.description, self:GetData("id", "00000"), self:GetData("name", "nobody"))
end