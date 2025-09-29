PLUGIN.name = "Nutscript-like Item Menu"
PLUGIN.author = "gumlefar"
PLUGIN.desc = "Replaces the default awful Helix item interaction menu."

ix.menu = ix.menu or {}
ix.menu.list = ix.menu.list or {}

--OVERRIDE 
if (CLIENT) then
    -- Backup the original Helix menu function if not already saved
    ix.menu.OpenDefault = ix.menu.OpenDefault or ix.menu.Open

    function ix.menu.Open(options, entity)
        -- Prevent opening multiple menus
        if IsValid(ix.menu.panel) then
            return false
        end

        -- If the entity is a player, use Helix's default menu
        if IsValid(entity) and entity:IsPlayer() then
            return ix.menu.OpenDefault(options, entity)
        end

        -- Otherwise, use your custom menu logic
        ix.menu.AddToList(options, entity)

        return true
    end

	surface.CreateFont("ixItemMenuFont", {
		font = "Consolas",
		size = 20,
		extended = true,
		weight = 500
	})
end

-- Adds a new menu to the list of drawn menus.
function ix.menu.AddToList(options, position, onRemove)
	-- Set up the width of the menu.
	local width = 0
	local entity	

	-- The font for the buttons.
	surface.SetFont("ixItemMenuFont")

	-- Set the width to the longest button width.
	for k, v in pairs(options) do
		width = math.max(width, surface.GetTextSize(tostring(k)))
	end

	-- If you supply an entity, then the menu will follow the entity.
	if (type(position) == "Entity") then
		-- Store the entity in the menu.
		entity = position
		-- The position will be the trace hit pos relative to the entity.
		position = entity:WorldToLocal(LocalPlayer():GetEyeTrace().HitPos)
	end

	for k,v in pairs(ix.menu.list) do
		if v.entity == entity then return -1 end
	end

	-- Add the new menu to the list.
	return table.insert(ix.menu.list, {
		-- Use the specified position or whatever the player is looking at.
		position = position or LocalPlayer():GetEyeTrace().HitPos,
		-- Options are the list with button text as keys and their callbacks as values.
		options = options,
		-- Add 8 to the width to give it a border.
		width = width + 8,
		-- Find how tall the menu is.
		height = table.Count(options) * 28,
		-- Store the attached entity if there is one.
		entity = entity,
		-- Called after the menu has faded out.
		onRemove = onRemove
	})
end

-- A function to draw all of the active menus or hide them when needed.
function ix.menu.DrawAll()
	local frameTime = FrameTime() * 30
	local mX, mY = ScrW() * 0.5, ScrH() * 0.5
	local position2 = LocalPlayer():GetPos()

	-- Loop through the current menus.
	for k, v in ipairs(ix.menu.list) do
		-- Get their position on the screen.
		local position
		local entity = v.entity

		if (entity) then
			-- Follow the entity.
			if (IsValid(entity)) then
				local realPos = entity:LocalToWorld(v.position)

				v.entPos = LerpVector(frameTime * 0.5, v.entPos or realPos, realPos)
				position = v.entPos:ToScreen()
			-- The attached entity is gone, remove the menu.
			else
				table.remove(ix.menu.list, k)

				if (v.onRemove) then
					v:onRemove()
				end

				continue
			end
		else
			position = v.position:ToScreen()
		end

		local width, height = v.width, v.height
		local startX, startY = position.x - (width * 0.5), position.y
		local alpha = v.alpha or 0
		-- Local player is within 96 units of the menu.
		local inRange = position2:DistToSqr(IsValid(v.entity) and v.entity:GetPos() or v.position) <= 9216
		-- Check that the center of the screen is within the bounds of the menu.
		local inside = (mX >= startX and mX <= (startX + width) and mY >= startY and mY <= (startY + height)) and inRange

		-- Make the menu more visible if the center is inside the menu or it hasn't peaked in alpha yet.
		if (!v.displayed or inside) then
			v.alpha = math.Approach(alpha or 0, 255, frameTime * 25)

			-- If this is the first time we reach full alpha, store it.
			if (v.alpha == 255) then
				v.displayed = true
			end
		-- Otherwise the menu should fade away.
		else
			v.alpha = math.Approach(alpha or 0, 0, inRange and frameTime or (frameTime * 45))

			-- If it has completely faded away, remove it.
			if (v.alpha == 0) then
				-- Remove the menu from being drawn.
				table.remove(ix.menu.list, k)

				if (v.onRemove) then
					v:onRemove()
				end

				-- Skip to the next menu, the logic for this one is done.
				continue
			end
		end

		-- Store which button we're on.
		local i = 0
		-- Determine the border of the menu.
		local x2, y2, w2, h2 = startX - 4, startY - 4, width + 8, height + 8

		alpha = v.alpha * 0.9

		-- Draw the dark grey background.
		surface.SetDrawColor(40, 40, 40, alpha)
		surface.DrawRect(x2, y2, w2, h2)

		-- Draw a subtle gradient over it.
		surface.SetDrawColor(250, 250, 250, alpha * 0.025)
		--surface.SetMaterial(gradient)
		surface.DrawTexturedRect(x2, y2, w2, h2)

		-- Draw an outline around the menu.
		surface.SetDrawColor(0, 0, 0, alpha * 0.25)
		surface.DrawOutlinedRect(x2, y2, w2, h2)

		-- Loop through all of the buttons.
		for k2, v2 in SortedPairs(v.options) do
			-- Determine where the button starts.
			local y = startY + (i * 28)

			-- Check if the button is hovered.
			if (inside and mY >= y and mY <= (y + 28)) then
				-- If so, draw a colored rectangle to indicate it.
				surface.SetDrawColor(ColorAlpha(ix.config.Get("color"), v.alpha + math.cos(RealTime() * 8) * 40))
				surface.DrawRect(startX, y, width, 28)
			end

			-- Draw the button's text.
			ix.util.DrawText(k2, startX + 4, y + 1, ColorAlpha(color_white, v.alpha), nil, nil, "ixItemMenuFont")

			-- Make sure we draw the next button in line.
			i = i + 1
		end
	end
end

function PLUGIN:HUDPaint()
	ix.menu.DrawAll()
end

function ix.menu.OnButtonPressed(menu, callback)
	table.remove(ix.menu.list, menu)

	if (callback) then
		callback()

		return true
	end

	return false
end

function ix.menu.GetActiveMenu()
	local mX, mY = ScrW() * 0.5, ScrH() * 0.5
	local position2 = LocalPlayer():GetPos()

	-- Loop through the current menus.
	for k, v in ipairs(ix.menu.list) do
		-- Get their position on the screen.
		local position
		local entity = v.entity
		local width, height = v.width, v.height

		if (entity) then
			-- Follow the entity.
			if (IsValid(entity)) then
				position = (v.entPos or entity:LocalToWorld(v.position)):ToScreen()
			-- The attached entity is gone, remove the menu.
			else
				table.remove(ix.menu.list, k)

				continue
			end
		else
			position = v.position:ToScreen()
		end

		-- Get where the menu starts and ends.
		local startX, startY = position.x - (width * 0.5), position.y
		-- Local player is within 96 units of the menu.
		local inRange = position2:Distance(IsValid(v.entity) and v.entity:GetPos() or v.position) <= 96
		-- Check that the center of the screen is within the bounds of the menu.
		local inside = (mX >= startX and mX <= (startX + width) and mY >= startY and mY <= (startY + height)) and inRange

		if (inRange and inside) then
			local choice
			local i = 0

			-- Loop through all of the buttons.
			for k2, v2 in SortedPairs(v.options) do
				-- Determine where the button starts.
				local y = startY + (i * 28)

				-- Check if the button is hovered.
				if (inside and mY >= y and mY <= (y + 28)) then
					choice = v2

					break
				end

				-- Make sure we draw the next button in line.
				i = i + 1
			end

			return k, choice
		end
	end
end

if CLIENT then 

	function PLUGIN:PlayerBindPress(client, bind, pressed)
		if ((bind:find("use") or bind:find("attack")) and pressed) then
			local menu, callback = ix.menu.GetActiveMenu()

			if (menu and ix.menu.OnButtonPressed(menu, callback)) then
				return true
			end
		end
	end

end