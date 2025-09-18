local PLUGIN = PLUGIN

PLUGIN.name = "Sound URL"
PLUGIN.description = "Play sounds with URLs"
PLUGIN.author = "Created by P!"


local active_sounds = {}

netstream.Hook("SendSound", function(input)
	local name = input[2]
	local loop = input[4]
	if not name then
		name = input[1]
	end

	if not loop then
		sound.PlayFile( "sound/" .. input[1], "", function( station )
			if IsValid(station) then
				station:Play()
				if (input[3]) then
					station:SetVolume(input[3])
				end
				active_sounds[name] = station;
			end
		end)
	else
		sound.PlayFile( "sound/" .. input[1], "noblock", function( station )
			if IsValid(station) then
			station:EnableLooping(true)
				station:Play()
				if (input[3]) then
					station:SetVolume(input[3])
				end
				active_sounds[name] = station;
			end
		end)
	end
end)

netstream.Hook("Send3dSound", function (input)
	local name = input[2]
	local vol = input[3]
	local loop = input[4]
	local pos = input[5]
	if not name then
		name = input[1]
	end
	sound.PlayFile("sound/" .. input[1], "3d", function(station)
		if IsValid(station) then
			if loop then
				station:EnableLooping(true)
			end

			if vol then
				station:SetVolume(vol)
			end
			station:SetPos(pos)
			station:EnableLooping(true)
			station:Play()
			active_sounds[name] = station;
		end
	end)
end)

netstream.Hook("SendURLSound", function(input)
	local name = nil
	if (input[2]) then
		name = input[2]
	else
		name = input[1]
	end
	sound.PlayURL( input[1], "", function( station )
		if IsValid(station) then
			if (input[3]) then
				station:SetVolume(input[3])
			end
			station:Play()
			active_sounds[name] = station;
		end
	end)
end)

netstream.Hook("StopSound", function(file)
	 if file == "all" then
	 	LocalPlayer():ConCommand("stopsound")
		for k, v in pairs(active_sounds) do
			v:Stop()
			v = nil;
		end
	 end
	 if IsValid(active_sounds[file])  then
	 	active_sounds[file]:Stop();
		active_sounds[file] = nil;
	elseif file == nil then
		for k, v in pairs (active_sounds) do
			v:Stop();
			v = nil;
		end
	 end
end)

ix.command.Add("PlayURL", {
    description = "Play a sound URL, will keep playing if used more than once.",
    adminOnly = true,
    arguments = {ix.type.string, ix.type.number, bit.bor(ix.type.string, ix.type.optional)},
    OnRun = function(self, client, file, vol, id)
        if (SERVER) then
            local name = id or file
            for _, ply in ipairs(player.GetAll()) do
                if ply:IsAdmin() then
                    ply:Notify(client:Name() .. " has started playing a sound with ID: " .. name)
                end
            end
            netstream.Start(nil, "SendURLSound", {file, id, vol})
        end
    end
})
ix.command.Add("StopSound", {
    description = "Stop a playing sound (can be one made from a URL or a file.)",
    adminOnly = true,
    arguments = {bit.bor(ix.type.string, ix.type.optional)},
    OnRun = function(self, client, file)
        if (SERVER) then
            netstream.Start(nil, "StopSound", file)
        end
    end
})