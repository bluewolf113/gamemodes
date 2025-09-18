local PLUGIN = PLUGIN

PLUGIN.ColorProps = PLUGIN.ColorProps or {}

local COLOR_ACTIVE = {
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0.04,
	["$pp_colour_addb"] = 0,
	["$pp_colour_brightness"] = -0.05,
	["$pp_colour_contrast"] = 1.13,
	["$pp_colour_colour"] = 0.4,
	["$pp_colour_mulr"] = 0.03,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0.08
}

-- PostPlayerLoadout network all the colored props
net.Receive("UpdateColorPropsTable", function()
	PLUGIN.ColorProps = {}

	local unsortedColorProps = net.ReadTable()

	-- clientside ColorProps can be sequential
	for _, v in pairs(unsortedColorProps) do
		PLUGIN.ColorProps[#PLUGIN.ColorProps + 1] = v
	end
end)

-- Used to Lerp COLOR_ACTIVE
function PLUGIN:Think()
	if (!self.bShouldLerp) then return end

	local base   = self.bShouldShowColor and 0 or 1
	local target = self.bShouldShowColor and 1 or 0

	-- time in seconds for the animation to complete. 5 -> 5 seconds
	local fadeTime = 5

	COLOR_ACTIVE["$pp_colour_colour"] = Lerp(((SysTime() - self.startLerp) / fadeTime), base, target)

	if ((SysTime() - self.startLerp) > fadeTime) then
		self.bShouldLerp = false

	end
end

function PLUGIN:RenderScreenspaceEffects()

	DrawColorModify(COLOR_ACTIVE)
	DrawSharpen( 0, 0 )
end

-- temp function to test black bars
--function PLUGIN:HUDPaint()
--    surface.SetDrawColor(0, 0, 0, 255)
--    local height = ScrH() / 12
--
--    surface.DrawRect(0, (ScrH() - height), ScrW(), height)
--    surface.DrawRect(0, 0, ScrW(), height)
--end

function PLUGIN:PostDrawEffects()

	cam.Start3D(EyePos(), EyeAngles())

	for _, v in ipairs(self.ColorProps) do
		if (!IsValid(v)) then continue end

		if (self.visualWhitelist[v:GetClass()]) then
			v:DrawModel()
		end
	end

	cam.End3D()
end