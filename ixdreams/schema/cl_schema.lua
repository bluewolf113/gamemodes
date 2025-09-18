
-- Here is where all of your clientside functions should go.

-- Example client function that will print to the chatbox.
function Schema:ExampleFunction(text, ...)
	if (text:sub(1, 1) == "@") then
		text = L(text:sub(2), ...)
	end

	LocalPlayer():ChatPrint(text)
end

-- redefine bar.add to include icon

function ix.bar.Add(getValue, color, priority, identifier, icon)
	
	if (identifier and ix.bar.Get(identifier)) then
		ix.bar.Remove(identifier)
	end

	local index = #ix.bar.list + 1

	color = color or Color(math.random(150, 255), math.random(150, 255), math.random(150, 255))
	priority = priority or index

	ix.bar.list[index] = {
		index = index,
		color = color,
		priority = priority,
		GetValue = getValue,
		identifier = identifier,
		icon = icon,
		panel = IsValid(ix.gui.bars) and ix.gui.bars:AddBar(index, color, priority, icon)
	}
	

	return priority
end

function ix.bar.Remove(identifier)
	local bar = ix.bar.Get(identifier)
	
	if (bar) then
		
		table.remove(ix.bar.list, bar.index)

		if (IsValid(ix.gui.bars)) then
			ix.gui.bars:RemoveBar(bar.panel)
		end
	end
end

do
	ix.bar.Add(function()
		return math.max(LocalPlayer():Health() / LocalPlayer():GetMaxHealth(), 0)
	end, Color(220, 30, 30), 1, "health", "ixgui/medical-pack.png")

	ix.bar.Add(function()
		return math.min(LocalPlayer():Armor() / 100, 1)
	end, Color(190, 90, 255), 2, "armor", "ixgui/kevlar-vest.png")
end


RunConsoleCommand("playx_fullscreen", 0)

hook.Remove("Think", "PlayXFullscreenHotkey")



