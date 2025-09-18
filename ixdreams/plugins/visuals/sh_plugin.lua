
local PLUGIN = PLUGIN

PLUGIN.name = "Visuals"
PLUGIN.author = "Gary Tate"
PLUGIN.description = "Adaptable and custom visuals for Kill City II"

if (CLIENT) then
	PLUGIN.bShouldLerp = false
	PLUGIN.startLerp = 0
	PLUGIN.bShouldShowColor = false
end

CAMI.RegisterPrivilege({
	Name = "Helix - Manage Prop Colors",
	MinAccess = "admin"
})

-- Make sure that only whitelisted entities suppress engine lighting
-- in PostDrawEffects or else we could run into some wonderful crashing.
PLUGIN.visualWhitelist = {
	["prop_physics"] = true,
    ["ix_item"] = true,
    ["ix_container"] = true,
	["player"] = true
}

properties.Add("toggle_prop_color", {
	MenuLabel = "Toggle Prop Color",
	MenuIcon = "icon16/color_wheel.png",
	Order = 30,

	Filter = function(self, entity, client)
		if (!PLUGIN.visualWhitelist[entity:GetClass()]) then return false end

		return CAMI.PlayerHasAccess(client, "Helix - Manage Prop Colors", nil)
	end,

	Action = function(self, entity)
		self:MsgStart()
			net.WriteEntity(entity)
		self:MsgEnd()
	end,

	Receive = function(self, length, client)
		local entity = net.ReadEntity()

		if (!IsValid(entity)) then return end
		if (!self:Filter(entity, client)) then return end

		entity.bShowColor = !entity.bShowColor or true

		local bHasValue = table.KeyFromValue(PLUGIN.ColorProps, entity)

		if (bHasValue) then
			PLUGIN.ColorProps[bHasValue] = nil
		else
			PLUGIN.ColorProps[entity:GetCreationID()] = entity
		end

		net.Start("UpdateColorPropsTable")
			net.WriteTable(PLUGIN.ColorProps)
		net.Broadcast()
	end
})

ix.util.Include("cl_plugin.lua", "client")
ix.util.Include("sv_plugin.lua", "server")
