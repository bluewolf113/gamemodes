ITEM.name = "Mysterious Artifact"
ITEM.description = "An item that holds unknown properties."
ITEM.model = "models/props_lab/box01a.mdl"

-- Attribute-based descriptions
ITEM.attributeDescriptions = {
    biology = {
        "Biology: The surface has traces of organic material, as if it were once alive.",
        "Biology: You notice intricate patterns that resemble cellular structures."
    },
    shivers = {
        "Shivers: The artifact radiates an unsettling energy—you feel watched.",
        "Shivers: Holding it too long makes your skin crawl."
    },
    tabularasa = {
        "Who am I?",
        "Why am I here?",
        "Who are they?",
        "I don't know."
    },
    traveler = {
        "Traveler: This resembles artifacts found in distant regions, but its origins remain unclear.",
        "Traveler: You recognize symbols that appear similar to those in ancient maps."
    }
}

-- Neutral descriptions (always possible, no attribute prefix)
ITEM.neutralDescriptions = {
    "Despite its ordinary appearance, the artifact carries an undeniable sense of mystery.",
    "The longer you look at it, the more you feel as if it’s watching you back.",
    "Something about it lingers in your mind—neither threatening nor reassuring.",
    "It looks completely mundane, yet its presence feels strangely significant.",
    "No matter how closely you examine it, you can't seem to figure out why it feels familiar."
}

-- Function to generate and store a player's unique examined description
function ITEM:Examine(player)
    local charID = player:GetCharacter():GetID()
    local uniqueKey = "examinedDescription_" .. charID

    if not self:GetData(uniqueKey) then
        local possibleDescriptions = {}

        -- Collect attribute-based descriptions if applicable
        for attr, descList in pairs(self.attributeDescriptions) do
            if player:GetCharacter():GetAttribute(attr, 0) == 1 then
                table.insert(possibleDescriptions, descList[math.random(#descList)])
            end
        end

        -- Always include a chance for a neutral description
        if math.random() < 0.3 or #possibleDescriptions == 0 then  -- 30% chance for a neutral description
            table.insert(possibleDescriptions, self.neutralDescriptions[math.random(#self.neutralDescriptions)])
        end

        -- Select a final description randomly
        local chosenDescription = possibleDescriptions[math.random(#possibleDescriptions)]

        -- Store the generated description
        self:SetData(uniqueKey, chosenDescription)
    end
end

-- Adding the "Examine" option in the item menu
ITEM.functions.Examine = {
    name = "Examine",
    tip = "Look closely at the item",
    icon = "icon16/magnifier.png",
    OnRun = function(item)
        item:Examine(item.player)
        return false
    end,
    OnCanRun = function(item)
        local charID = item.player:GetCharacter():GetID()
        local uniqueKey = "examinedDescription_" .. charID

        -- If a description already exists, disable the option
        return not item:GetData(uniqueKey)
    end
}

-- Populate tooltip with the player's personal examined description
function ITEM:PopulateTooltip(tooltip)
    local charID = LocalPlayer():GetCharacter():GetID()
    local uniqueKey = "examinedDescription_" .. charID
    local examinedDesc = self:GetData(uniqueKey)

    if examinedDesc then
        local row = tooltip:AddRowAfter("description", "examinedDescription")
        row:SetText(examinedDesc) -- Attribute descriptions already contain their prefixes
        row:SetTextColor(Color(255, 255, 255)) -- Keep text readable
        row:SetBackgroundColor(Color(255, 215, 0)) -- Yellow background
        row:SizeToContents()
    end
end
