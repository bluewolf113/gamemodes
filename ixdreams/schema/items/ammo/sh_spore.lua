ITEM.name = "Spore Fruit"
ITEM.category = "Food"
ITEM.model = "models/opfor/spore.mdl"
ITEM.ammo = "AirboatGun" -- type of the ammo
ITEM.ammoAmount = 1 -- amount of the ammo
ITEM.description = "A green, organic sphere."
ITEM.hunger = 10
ITEM.thirst = 8

ITEM.functions.Eat = {
	OnRun = function(item)
		local client = item.player
		local character = client:GetCharacter()
		
		client:SetHealth(math.Clamp(client:Health() + 4, 0, client:GetMaxHealth()))
		client:EmitSound("player/footsteps/sand1.wav", 75, 70, 1.0)
		
		character:AddNeed("hunger", item.hunger)
		character:AddNeed("thirst", item.thirst)
	end,
}

ITEM.functions.use.OnRun = function(item)
		local ply = item.player
		-- Call SLVBase ammo function
		if IsValid(ply) then
			if ply.AddAmmunition ~= nil then
				ply:AddAmmunition("spore", 1)
			end
		end
		return true
end

ITEM.functions.use.OnCanRun = function(item)
	local ply = item.player
    for _, weapon in ipairs(ply:GetWeapons()) do
        if weapon:GetClass() == "weapon_sporelauncher" then
            return true
        end
    end
    return false
end