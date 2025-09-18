local PLUGIN = PLUGIN
PLUGIN.name = "Gman Effects"
PLUGIN.author = "kingbolt"
PLUGIN.description = "Goverment  Man."

ix.util.Include("cl_plugin.lua")

if SERVER then
	util.AddNetworkString("ix_GmanBlackoutEffect")
	util.AddNetworkString("ix_GmanUnBlackoutEffect")
    util.AddNetworkString("ix_GmanFreezeEffect")
    util.AddNetworkString("ix_GmanUnFreezeEffect")
	util.AddNetworkString("ix_GmanCharacterInvisible")
	util.AddNetworkString("ix_GmanCharacterVisible")
end

ix.command.Add("GmanFreeze", {
    description = "G-man the target.",
    adminOnly = true,
    arguments = {ix.type.player},
    OnRun = function(self, client, target)
        if not IsValid(target) then return end
		local character = target:GetCharacter()
        target:Lock()
		target:SetNotSolid(true)
        character:SetData("ix_GmanFrozen", true)
        -- Send the white flash effect and freeze screen to the target
        net.Start("ix_GmanFreezeEffect")
			net.WritePlayer(client)
        net.Send(target)
		
		local plyTbl = {target, client}
		
		target:SetNoDraw(true)
		
		net.Start("ix_GmanCharacterInvisible")
			net.WritePlayer(target)
		net.SendOmit(plyTbl)

    end
})

ix.command.Add("GmanTeleport", {
    description = "Teleport the target player to your aim position and G-man them.",
    adminOnly = true,
    arguments = {ix.type.player},
    OnRun = function(self, client, target)
        if not IsValid(target) then return end
        local trace = client:GetEyeTrace()
        if trace.Hit then
            target:SetPos(trace.HitPos)
            ix.command.Get("GManFreeze").OnRun(self, client, target)
        end
    end
})

ix.command.Add("GmanBlackout", {
    description = "Void the target.",
    adminOnly = true,
    arguments = {ix.type.player},
    OnRun = function(self, client, target)
        if not IsValid(target) then return end
		local character = target:GetCharacter()
		
        target:Lock()
		target:SetNotSolid(true)

        net.Start("ix_GmanBlackoutEffect")
			net.WritePlayer(client)
        net.Send(target)
		
		if not character:GetData("ix_GmanFrozen", false) then
			
			target:SetNoDraw(true)
			
			net.Start("ix_GmanCharacterInvisible")
				net.WritePlayer(client)
			net.SendOmit(target)
		end	
		character:SetData("ix_GmanBlackout", true)		
    end
})

ix.command.Add("UnGman", {
    description = "Reverts the effects of GManFreeze or GmanBlackout on the target player.",
    adminOnly = true,
    arguments = {ix.type.player},
    OnRun = function(self, client, target)
		if not IsValid(target) then return end
		local character = target:GetCharacter()
		
		local frozen = character:GetData("ix_GmanFrozen", nil) or false
		local blackout = character:GetData("ix_GmanBlackout", nil) or false
		
		if frozen or blackout then
			target:UnLock()
			target:SetNotSolid(false)
			
			target:SetNoDraw(false)
			
			net.Start("ix_GmanCharacterVisible")
				net.WritePlayer(target)
			net.SendOmit(target)
			
			if frozen then
				net.Start("ix_GmanUnFreezeEffect")
					net.WritePlayer(client)
				net.Send(target)
			end
			
			if blackout then
				net.Start("ix_GmanUnBlackoutEffect")
					net.WritePlayer(client)
				net.Send(target)	
			end
			
			character:SetData("ix_GmanFrozen", false)
			character:SetData("ix_GmanBlackout", false)
		end	
	end		
})
