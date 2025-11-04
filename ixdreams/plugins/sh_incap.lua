local PLUGIN = PLUGIN

PLUGIN.name = "Downed State"
PLUGIN.author = "blue"
PLUGIN.description = "Chance-based downed state using Helix acts and death screen."

util.AddNetworkString("ixDownedState")

function PLUGIN:PlayerShouldTakeDamage(client, attacker)
    if client:GetNetVar("ixDowned") then return false end
end

function PLUGIN:EntityTakeDamage(target, dmgInfo)
    if not target:IsPlayer() then return end
    if target:GetNetVar("ixDowned") then return end

    local hp = target:Health()
    local dmg = dmgInfo:GetDamage()

    if dmg >= hp then
        if math.random(1, 3) == 1 then
            dmgInfo:SetDamage(0)
            self:EnterDownedState(target)
        end
    end
end

net.Receive("ixDownedState", function()
    local client = net.ReadEntity()
    if not IsValid(client) then return end
    if client ~= LocalPlayer() then return end



    chat.AddText(Color(255, 100, 100), "You are downed. Await recovery...")
end)

function PLUGIN:EnterDownedState(client)
    client:SetHealth(1)
    client:SetNetVar("ixDowned", true)
    client:SetMoveType(MOVETYPE_NONE)
    
    ix.command.Run(client, "ActDown", {2})

    net.Start("ixDownedState")
    net.WriteEntity(client)
    net.Send(client)

    local duration = math.random(60, 120)
    timer.Simple(duration, function()
        if IsValid(client) then
            client:SetNetVar("ixDowned", nil)
            client:SetMoveType(MOVETYPE_WALK)
            ix.anim.SetIdleOverride(client)
            client:SetHealth(client:GetMaxHealth())
        end
    end)
end


-- Command: /down <target>
ix.command.Add("Down", {
    description = "Force a player into the downed state.",
    adminOnly = true,
    arguments = {ix.type.player},
    OnRun = function(self, client, target)
        if target:GetNetVar("ixDowned") then
            return "That player is already downed."
        end

        PLUGIN:EnterDownedState(target)
        client:ChatPrint("You have downed " .. target:Name() .. ".")
    end
})

-- Command: /revive <target>
ix.command.Add("Revive", {
    description = "Revive a player from the downed state.",
    adminOnly = true,
    arguments = {ix.type.player},
    OnRun = function(self, client, target)
        if not target:GetNetVar("ixDowned") then
            return "That player is not downed."
        end

        target:SetNetVar("ixDowned", nil)
        target:SetMoveType(MOVETYPE_WALK)
        ix.anim.SetIdleOverride(target)
        target:SetHealth(target:GetMaxHealth())

        client:ChatPrint("You have revived " .. target:Name() .. ".")
        target:ChatPrint("You have been revived.")
    end
})

function PLUGIN:PlayerBindPress(client, bind, bPressed)
    if (bind:find("+jump") and bPressed and client:GetNetVar("ixDowned", true)) then
		return false
	end
end