local PLUGIN = PLUGIN

ITEM.name = "Scrap Paper"
ITEM.description = "A torn strip of paper.%s"
ITEM.model = Model("models/props_c17/paper01.mdl")
ITEM.width = 1
ITEM.height = 1
ITEM.category = "Scrap"
ITEM.bAllowMultiCharacterInteraction = true

function ITEM:GetDescription()
	return self:GetData("owner", 0) == 0
		and string.format(self.description, "")
		or string.format(self.description, " There's something written on it.")
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