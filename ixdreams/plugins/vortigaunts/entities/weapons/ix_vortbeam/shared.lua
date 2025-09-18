if (SERVER) then
	AddCSLuaFile("shared.lua");
end;

if (CLIENT) then
	SWEP.Slot = 0;
	SWEP.SlotPos = 5;
	SWEP.DrawAmmo = false;
	SWEP.PrintName = "Vortibeam";
	SWEP.DrawCrosshair = true;
	
	game.AddParticles("particles/Vortigaunt_FX.pcf");
end

PrecacheParticleSystem("vortigaunt_beam");
PrecacheParticleSystem("vortigaunt_beam_b");
PrecacheParticleSystem("vortigaunt_charge_token");

SWEP.Instructions = "Primary Fire: Fire your beam.";
SWEP.Purpose = "Immediately kills the target that you fire it at.";
SWEP.Contact = "";
SWEP.Author	= "RJ";

SWEP.ViewModel = "";
SWEP.WorldModel 			= ""
SWEP.HoldType = "normal";

SWEP.AdminSpawnable = false;
SWEP.Spawnable = false;
  
SWEP.Primary.IsAlwaysRaised = true;
SWEP.Primary.DefaultClip = 0;
SWEP.Primary.Automatic = false;
SWEP.Primary.ClipSize = -1;
SWEP.Primary.Damage = 55;
SWEP.Primary.Delay = 3;
SWEP.Primary.Ammo = "";

SWEP.Secondary.DefaultClip = 0;
SWEP.Secondary.Automatic = false;
SWEP.Secondary.ClipSize = -1;
SWEP.Secondary.Delay = 0;
SWEP.Secondary.Ammo	= "";

SWEP.IsAlwaysRaised = true;

-- Called when the SWEP is deployed.
function SWEP:Deploy()
	self:SendWeaponAnim(ACT_VM_DRAW);
end;

-- Called when the SWEP is holstered.
function SWEP:Holster(switchingTo)
	self:SendWeaponAnim(ACT_VM_HOLSTER);
	
	return true;
end;

-- Called when the SWEP is initialized.
function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType);
end;

-- Called when the player attempts to primary fire.
function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay);

    if (self.Owner:OnGround()) then
        -- Always play the gesture first
        self.Owner:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GESTURE_RANGE_ATTACK1, true)

        -- Vortessence check after gesture
        local char = self.Owner:GetCharacter()
        if char then
            local vortessence = char:GetNeed("vortessence") or 0
            if vortessence < 10 then
                if SERVER then
                    self.Owner:Notify("Your Vortal Connection is exhausted.")
                end
                return -- stop here, no attack logic
            else
                char:SetNeed("vortessence", math.max(vortessence - 10, 0))
            end
        end

        -- Attack logic only runs if enough vortessence
        local chargeSound = CreateSound(self.Owner, "npc/vort/attack_charge.wav");
        chargeSound:Play();
        
        ParticleEffectAttach("vortigaunt_charge_token", PATTACH_POINT_FOLLOW, self.Owner, self.Owner:LookupAttachment("leftclaw"));
        ParticleEffectAttach("vortigaunt_charge_token", PATTACH_POINT_FOLLOW, self.Owner, self.Owner:LookupAttachment("rightclaw"));
        
        timer.Simple(0.55, function()
            if not IsValid(self) or not IsValid(self.Owner) then return end

            chargeSound:Stop();
            self.Owner:EmitSound("npc/vort/attack_shoot.wav");
            
            local tr = util.QuickTrace(self.Owner:EyePos(), self.Owner:EyeAngles():Forward()*5000, self.Owner);
            
            self.Owner:StopParticles();

            local leftClaw = self.Owner:LookupAttachment("leftclaw");

            if (leftClaw) then
                util.ParticleTracerEx(
                    "vortigaunt_beam", self.Owner:GetAttachment(leftClaw).Pos, tr.HitPos, true, self.Owner:EntIndex(), leftClaw
                );
            end;
            
            util.BlastDamage(self.Owner, self.Owner, tr.HitPos, 10, 400);
        end);
    end;
end


function SWEP:SecondaryAttack()
    self:SetNextSecondaryFire(CurTime() + 0.1)
    if self._chanting then return end

    self._chanting = true

    local ply = self.Owner
    if not IsValid(ply) then return end

    if SERVER then
        ply:SetMoveType(MOVETYPE_NONE)
        ply:Notify("You begin channeling Vortal energy...")
    end

    -- Loop animation
    ply:AnimRestartGesture(GESTURE_SLOT_CUSTOM, ACT_GESTURE_RANGE_ATTACK2, true)
    ply:DoAnimationEvent(ACT_VM_IDLE)

    -- Regen loop
    self._chantTimer = "vort_chant_" .. self:EntIndex()
    timer.Create(self._chantTimer, 1, 0, function()
        if not IsValid(self) or not IsValid(ply) or not ply:KeyDown(IN_ATTACK2) then
            self:StopChant()
            return
        end

        local char = ply:GetCharacter()
        if char then
            local current = char:GetNeed("vortessence") or 0
            char:SetNeed("vortessence", math.min(current + 3, 100))
        end

        ply:AnimRestartGesture(GESTURE_SLOT_CUSTOM, ACT_GESTURE_RANGE_ATTACK2, true)
    end)
end

function SWEP:StopChant()
    if not self._chanting then return end
    self._chanting = false

    timer.Remove(self._chantTimer)

    local ply = self.Owner
    if IsValid(ply) then
        if SERVER then
            ply:SetMoveType(MOVETYPE_WALK)
            ply:Notify("Vortal channeling ended.")
        end
        ply:AnimResetGestureSlot(GESTURE_SLOT_CUSTOM)
    end
end

function SWEP:Holster()
    self:StopChant()
    return true
end

function SWEP:OnRemove()
    self:StopChant()
end

