local PLUGIN = PLUGIN

if SERVER then
    util.AddNetworkString("ShowEnvEventMessage")
end

function PLUGIN:PlayerDeath(victim, inflictor, attacker)

    local char = victim:GetCharacter()



    if (char) then

        char:SetData("deathPos", victim:GetPos())

    end

end