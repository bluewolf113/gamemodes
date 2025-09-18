function Schema:ForceDermaSkin()
	return "ixdreams"
end

function Schema:CharacterLoaded()
	ix.needs.SetupBars()
end

local injTextTable = {
	[.3] = {"injMajor", Color(192, 57, 43)},
	[.6] = {"injLittle", Color(231, 76, 60)},
}

function Schema:GetInjuredText(client)
	local health = client:Health()

	for k, v in pairs(injTextTable) do
		if ((health / client:GetMaxHealth()) < k) then
			return v[1], v[2]
		end
	end
end

function Schema:GetUniqueText(client)
    local title = client:GetNetVar("Title")

    if title then
        return title
    end
end

-- function Schema:PopulateImportantCharacterInfo(client, character, container)
	-- local color = team.GetColor(client:Team())
	-- container:SetArrowColor(color)

	-- -- name
	-- local name = container:AddRow("name")
	-- name:SetImportant()
	-- name:SetText(hook.Run("GetCharacterName", client) or character:GetName())
	-- name:SetBackgroundColor(color)
	-- name:SizeToContents()

	
-- end

-- hook.Add("PopulateCharacterInfo", "DrawAdditionalInfo", function(entity, character, panel) -- unique text
		-- local client = character:GetPlayer()
		
		-- local uniqueTextData = hook.Run("GetUniqueText", client)
		-- if (uniqueTextData) then
			-- local uniqueText = panel:AddRow("uniqueText")

			-- uniqueText:SetText(L(uniqueTextData))
			-- uniqueText:SetBackgroundColor(Color(150, 150, 150))
			-- uniqueText:SizeToContents()
		-- end

		-- -- injured text
		-- local injureText, injureTextColor = hook.Run("GetInjuredText", client)

		-- if (injureText) then
			-- local injure = panel:AddRow("injureText")

			-- injure:SetText(L(injureText))
			-- injure:SetBackgroundColor(injureTextColor)
			-- injure:SizeToContents()
		-- end
	-- end)