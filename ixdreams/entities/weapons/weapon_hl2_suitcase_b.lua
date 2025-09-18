AddCSLuaFile()

SWEP.Base           = "weapon_base"
SWEP.PrintName      = "Suitcase (B)"
SWEP.Author         = "YourName"
SWEP.Category       = "Roleplay"
SWEP.Spawnable      = true

-- no ammo
SWEP.Primary.Ammo       = "none"
SWEP.Primary.ClipSize   = -1
SWEP.Primary.DefaultClip= -1
SWEP.Primary.Automatic  = false

SWEP.Secondary.Ammo      = "none"
SWEP.Secondary.ClipSize  = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic   = false

SWEP.ViewModel        = "models/props_c17/SuitCase001a.mdl"
SWEP.WorldModel       = "models/props_c17/SuitCase001a.mdl"
SWEP.UseHands         = true
SWEP.ViewModelFOV     = 54

SWEP.HoldType = "normal"

function SWEP:PrimaryAttack() end
function SWEP:SecondaryAttack() end

if CLIENT then
	local WorldModel = ClientsideModel(SWEP.WorldModel)

	-- Settings...
	WorldModel:SetSkin(1)
	WorldModel:SetNoDraw(true)

	function SWEP:DrawWorldModel()
		local _Owner = self:GetOwner()

		if (IsValid(_Owner)) then
            -- Specify a good position
			local offsetVec = Vector(11, -1.5, 0)
			local offsetAng = Angle(270, 0, 0)
			
			local boneid = _Owner:LookupBone("ValveBiped.Bip01_R_Hand") -- Right Hand
			if !boneid then return end

			local matrix = _Owner:GetBoneMatrix(boneid)
			if !matrix then return end

			local newPos, newAng = LocalToWorld(offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles())

			WorldModel:SetPos(newPos)
			WorldModel:SetAngles(newAng)

            WorldModel:SetupBones()
		else
			WorldModel:SetPos(self:GetPos())
			WorldModel:SetAngles(self:GetAngles())
		end

		WorldModel:DrawModel()
	end
end

if SERVER then
    -- Called when the player selects (draws) your SWEP
    function SWEP:Deploy()
        local ply = self:GetOwner()
        if IsValid(ply) and ply:IsPlayer() then
            -- send a /me emote
            ix.command.Parse(ply, "/moodwalk 5")
            ix.command.Parse(ply, "/moodstand 5")
        end

        -- Call base Deploy so the model actually shows
        if self.BaseClass and self.BaseClass.Deploy then
            return self.BaseClass.Deploy(self)
        end

        return true
    end

    -- Called when the player holsters (switches away from) your SWEP
    function SWEP:Holster(newWep)
        local ply = self:GetOwner()
        if IsValid(ply) and ply:IsPlayer() then
            ix.command.Parse(ply, "/moodwalk 0")
            ix.command.Parse(ply, "/moodstand 0")
        end

        -- returning true allows the holster to complete
        return true
    end
end