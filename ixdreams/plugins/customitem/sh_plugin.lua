
local PLUGIN = PLUGIN

PLUGIN.name = "Custom Items"
PLUGIN.author = "Gary Tate, Blue"
PLUGIN.description = "Enables staff members to create custom items."
PLUGIN.readme = [[
Enables staff members to create custom items.

Support for this plugin can be found here: https://discord.gg/mntpDMU
]]

ix.command.Add("CreateCustomItem", {
	description = "@cmdCreateCustomItem",
	superAdminOnly = true,
	arguments = {
		ix.type.string,
		ix.type.string,
		ix.type.string
	},
	OnRun = function(self, client, name, model, description)
		client:GetCharacter():GetInventory():Add("customitem", 1, {
			name = name,
			model = model,
			description = description
		})
	end
})
---
--ccustom shit here

ix.command.Add("CreateCustomOutfit", {
    description = "Creates a custom outfit in your inventory with a given name, model, description, and replacement model.",
    superAdminOnly = true,
    arguments = {
        ix.type.string, -- item name
        ix.type.string, -- icon model
        ix.type.string, -- description
        ix.type.string  -- replacement model
    },
    OnRun = function(self, client, name, model, description, replacement)
        client:GetCharacter():GetInventory():Add("customoutfit", 1, {
            name = name,
            model = model,
            description = description,
            replacement = replacement
        })
    end
})

ix.command.Add("CreateCustomWeapon", {
    description = "Creates a custom weapon in your inventory with defined properties.",
    superAdminOnly = true,
    arguments = {
        ix.type.string, -- name
        ix.type.string, -- model
        ix.type.string, -- description
        ix.type.string, -- weapon class (e.g. weapon_ar2)
        ix.type.string, -- ammo type (e.g. AR2)
        ix.type.number, -- ammo reserve
        ix.type.number  -- clip amount
    },
    OnRun = function(self, client, name, model, description, wepClass, ammoType, ammo, clip)
        client:GetCharacter():GetInventory():Add("customweapon", 1, {
            name = name,
            model = model,
            description = description,
            wepClass = wepClass,
            ammoType = ammoType,
            ammo = ammo,
            clip = clip
        })
    end
})

ix.command.Add("CreateCustomKey", {
    description = "@cmdCreateCustomKey",
    superAdminOnly = true,
    arguments = {
        ix.type.string, -- name
        ix.type.string, -- description
        ix.type.string, -- keyID
        bit.bor(ix.type.string, ix.type.optional) -- optional model
    },
    argumentNames = {"name", "description", "keyID", "model (optional)"},
    OnRun = function(self, client, name, description, keyID, model)
        client:GetCharacter():GetInventory():Add("customkey", 1, {
            name = name,
            description = description,
            keyID = keyID,
            model = model or "models/items/keys_001.mdl" -- fallback model
        })
    end
})


