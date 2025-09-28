PLUGIN.name = "Custom Item Examination"
PLUGIN.author = "Nicholas"
PLUGIN.description = "Allows items to define unique examination descriptions."

if SERVER then
    function PLUGIN:GenerateExaminedDescription(item, player)
        if not item.isExamineable then return end

        local charID = player:GetCharacter():GetID()
        local uniqueKey = "examinedDescription_" .. charID

        if not item:GetData(uniqueKey) then
            local possibleDescriptions = {}

            -- Attribute-based descriptions
            if item.attributeDescriptions then
                for attr, descList in pairs(item.attributeDescriptions) do
                    if player:GetCharacter():GetAttribute(attr, 0) == 1 then
                        table.insert(possibleDescriptions, descList[math.random(#descList)])
                    end
                end
            end

            -- Include neutral descriptions safely
            if math.random() < 0.3 or #possibleDescriptions == 0 then
                if item.neutralDescriptions and #item.neutralDescriptions > 0 then
                    table.insert(possibleDescriptions, item.neutralDescriptions[math.random(#item.neutralDescriptions)])
                end
            end

            if #possibleDescriptions > 0 then
                local chosenDescription = possibleDescriptions[math.random(#possibleDescriptions)]
                item:SetData(uniqueKey, chosenDescription)
            end
        end
    end
end

if CLIENT then
    function PLUGIN:PopulateItemTooltip(tooltip, item)
        if not item.isExamineable then return end

        local charID = LocalPlayer():GetCharacter():GetID()
        local uniqueKey = "examinedDescription_" .. charID
        local examinedDesc = item:GetData(uniqueKey)

        if examinedDesc then
            local row = tooltip:AddRow("examinedDescription")
            row:SetText(examinedDesc)
            row:SetTextColor(Color(255, 255, 255))
            row:SetBackgroundColor(Color(255, 215, 0)) -- Yellow background
            row:SizeToContents()
        end
    end
end

function PLUGIN:InitializedPlugins()
    for _, item in pairs(ix.item.list) do
        if item.isExamineable then
            item.functions.Examine = {
                name = "Examine",
                tip = "Look closely at the item",
                icon = "icon16/magnifier.png",
                OnRun = function(item)
                    local owner = item:GetOwner()
                    if IsValid(owner) then
                        PLUGIN:GenerateExaminedDescription(item, owner)
                    end
                    return false
                end,
                OnCanRun = function(item)
                    local owner = item:GetOwner()
                    if not IsValid(owner) then return false end
                    local charID = owner:GetCharacter():GetID()
                    local uniqueKey = "examinedDescription_" .. charID
                    return not item:GetData(uniqueKey)
                end
            }
        end
    end
end
