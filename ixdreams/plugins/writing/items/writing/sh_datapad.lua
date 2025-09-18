
local PLUGIN = PLUGIN

ITEM.name = "Piece of Paper"
ITEM.description = "They used to say the pen is mightier than the sword. That's because they didn't have Colt 45's yet. %s"
ITEM.price = 0
ITEM.model = Model("models/props_lab/papersheet001a.mdl")
ITEM.width = 1
ITEM.height = 1
ITEM.business = true
ITEM.bAllowMultiCharacterInteraction = true
ITEM.category = "Writing"

function ITEM:GetDescription()
	return self:GetData("owner", 0) == 0
		and string.format(self.description, "The note is blank.")
		or string.format(self.description, "There's some stuff written on it.")
end

function ITEM:SetText(text, character)
	text = tostring(text):sub(1, PLUGIN.maxLength)

	self:SetData("text", text, false, false, true)
	self:SetData("owner", character and character:GetID() or 0)
end

ITEM.functions.View = {
	OnRun = function(item)
		netstream.Start(item.player, "ixViewPaper", item:GetID(), item:GetData("text", ""), 0)
		return false
	end,

	OnCanRun = function(item)
		local owner = item:GetData("owner", 0)

		return owner != 0
	end
}

ITEM.functions.Edit = {
	OnRun = function(item)
		netstream.Start(item.player, "ixViewPaper", item:GetID(), item:GetData("text", ""), 1)
		return false
	end,

	OnCanRun = function(item)
		local owner = item:GetData("owner", 0)
		local client = item.player

		return (owner == 0 or owner == item.player:GetCharacter():GetID()) or client:IsAdmin()
	end
}

ITEM.functions.take.OnCanRun = function(item)
	local owner = item:GetData("owner", 0)

	return IsValid(item.entity) and (owner == 0 or owner == item.player:GetCharacter():GetID())
end