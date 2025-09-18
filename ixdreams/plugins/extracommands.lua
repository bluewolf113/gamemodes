PLUGIN.name = "Extra Commands"
PLUGIN.author = "P!"
PLUGIN.desc = "A few useful commands."

ix.command.Add("spawnitem", {
	description = "Spawns an item where you look",
	adminOnly = true,
	arguments = {
		ix.type.string,
	},
	OnRun = function(self, client, itemIDToSpawn)

		if (IsValid(client) and client:GetChar()) then
			local uniqueID = itemIDToSpawn:lower()
			if (!ix.item.list[uniqueID]) then
				for k, v in SortedPairs(ix.item.list) do
					if (ix.util.StringMatches(v.name, uniqueID)) then
						uniqueID = k
						break
					end
				end
			end

			if(!ix.item.list[uniqueID]) then
				client:Notify("No item exists with this unique ID.")
				return
			end

            local aimPos = client:GetEyeTraceNoCursor().HitPos

            aimPos:Add(Vector(0, 0, 10))

            ix.item.Spawn(uniqueID, aimPos)

		end
	end
})


ix.command.Add("plytogglehidden", {
	description = "Hides the given player from being displayed on the scoreboard.",
	adminOnly = true,
	arguments = {
		ix.type.player
	},
	OnRun = function (self, client, target)
		if (target) then
			if target:GetNetVar("scoreboardhidden", false) then
				target:SetNetVar("scoreboardhidden", false)
				client:Notify(target:GetName().." is now displayed on the scoreboard.")
			else
				target:SetNetVar("scoreboardhidden", true)
				client:Notify(target:GetName().." has been hidden on the scoreboard.")
			end
		end
	end
})

function PLUGIN:ShouldShowPlayerOnScoreboard(client)
	if client:GetNetVar("scoreboardhidden", false) == true then
		return false
	end
end

ix.command.Add("coinflip", {
	OnRun = function(self, client, arguments)
		local coinSide = math.random(0, 1);
		if (coinSide > 0) then
			ix.chat.Send(client, "iteminternal", "flips a coin, and it lands on heads.");
		else
			ix.chat.Send(client, "iteminternal", "flips a coin, and it lands on tails.");
		end
	end,
});

------------------

ix.command.Add("RagdollPlayer", {
    description = "Ragdoll a player for a set duration.",
    arguments = {
        ix.type.player,  -- Target player
        ix.type.number   -- Duration in seconds
    },
    adminOnly = true, -- Optional: restrict to admins
    OnRun = function(self, ply, target, duration)
        if not IsValid(target) or duration <= 0 then
            return "Invalid target or duration."
        end

        target:SetRagdolled(true, duration)
        ix.util.Notify(target:Name() .. " has been ragdolled for " .. duration .. " seconds.", ply)

        return
    end
})

ix.command.Add("UnRagdollPlayer", {
    description = "Force a ragdolled player to stand up immediately.",
    arguments = {
        ix.type.player  -- Target player
    },
    adminOnly = true, -- Optional: restrict to admins
    OnRun = function(self, ply, target)
        if not IsValid(target) then
            return "Invalid target."
        end

        target:SetRagdolled(true, 0)
        ix.util.Notify(target:Name() .. " has been unragdolled. ", ply)

        return
    end
})

