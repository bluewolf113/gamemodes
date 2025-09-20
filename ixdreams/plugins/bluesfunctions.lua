local PLUGIN = PLUGIN

PLUGIN.name = "Blue's Stuff"
PLUGIN.description = "Stuff blue adds that he's always wanted."
PLUGIN.author = "Blue and Copilot"

--hopefully this works, copilot...
if CLIENT then
    -- Modify the tooltip distance settings
    function PLUGIN:InitializedSchema()
        -- Override the tooltip visibility range
        ix.config.Set("maximumTooltipDistance", 512) -- Adjust value as needed
    end

    -- Hook into Helix’s tooltip logic
    function PLUGIN:ShouldDrawEntityInfo(entity)
        if not IsValid(entity) then return false end

        local client = LocalPlayer()
        local distance = client:GetPos():Distance(entity:GetPos())

        -- Increase default tooltip visibility range
        return distance <= 512 -- Modify this value as needed
    end
end

--------player menu stuff


PLUGIN.name = "Player Recognition & Nicknames"
PLUGIN.author = "Your Name"
PLUGIN.description = "Allows players to recognize others and set custom nicknames."

if SERVER then
    util.AddNetworkString("ixRecognizePlayer")
    util.AddNetworkString("ixSetNickname")
    util.AddNetworkString("ixRequestNickname")

    -- Handle player recognition request
    net.Receive("ixRecognizePlayer", function(_, sender)
        local target = net.ReadEntity()
        if not IsValid(sender) or not sender:GetCharacter() or not IsValid(target) or not target:GetCharacter() then return end

        local senderID = sender:GetCharacter():GetID()
        target:GetCharacter():Recognize(senderID) -- Mark target as recognized
    end)

    -- Handle nickname setting or removal
    net.Receive("ixSetNickname", function(_, sender)
        local target, nickname = net.ReadEntity(), net.ReadString():Trim()
        if not IsValid(sender) or not sender:GetCharacter() or not IsValid(target) or not target:GetCharacter() then return end

        local savedNicknames = sender:GetCharacter():GetData("nicknames", {})
        savedNicknames[target:GetCharacter():GetID()] = (nickname ~= "" and nickname) or nil -- Remove if empty
        sender:GetCharacter():SetData("nicknames", savedNicknames)
    end)

    -- Send stored nicknames **only after character loads** to prevent missing data
    hook.Add("PlayerLoadedCharacter", "ixSendSavedNicknames", function(client)
        timer.Simple(2, function()
            if not IsValid(client) or not client:GetCharacter() then return end
            local savedNicknames = client:GetCharacter():GetData("nicknames", {})
            net.Start("ixRequestNickname")
                net.WriteTable(savedNicknames)
            net.Send(client)
        end)
    end)
end

if CLIENT then
    local nicknameCache = {}

    -- Receive stored nicknames **only once per session**
    net.Receive("ixRequestNickname", function()
        nicknameCache = net.ReadTable()
    end)

    -- Adds recognition & nickname options to entity menu
    function PLUGIN:GetPlayerEntityMenu(client, options)
        options["Identify self"] = function()
            net.Start("ixRecognizePlayer")
                net.WriteEntity(client)
            net.SendToServer()
        end

        options["Set Nickname"] = function()
            Derma_StringRequest("Set Nickname", "Enter a nickname.", "",
                function(text)
                    local charID = client:GetCharacter() and client:GetCharacter():GetID()
                    if charID then
                        nicknameCache[charID] = text ~= "" and text or nil -- Remove locally if empty
                        net.Start("ixSetNickname") -- Persist change to server
                            net.WriteEntity(client)
                            net.WriteString(text)
                        net.SendToServer()
                    end
                end)
        end
    end

    -- Modify tooltips & chat to display custom nickname
    function PLUGIN:GetCharacterName(client)
        if client == LocalPlayer() then return client:GetCharacter():GetName() end
        local charID = client:GetCharacter() and client:GetCharacter():GetID()
        return (charID and nicknameCache[charID]) or client:GetCharacter():GetName()
    end
end

if CLIENT then
    local nicknameCache = {}

    -- Receive stored nicknames once per session
    net.Receive("ixRequestNickname", function()
        nicknameCache = net.ReadTable()
    end)

    -- Adds recognition & nickname options to entity menu
    function PLUGIN:GetPlayerEntityMenu(client, options)
        options["Identify Self"] = function()
            net.Start("ixRecognizePlayer")
                net.WriteEntity(client)
            net.SendToServer()
        end

        options["Set Nickname"] = function()
            Derma_StringRequest("Set Nickname", "Enter a nickname", "",
                function(text)
                    local charID = client:GetCharacter():GetID()
                    nicknameCache[charID] = text ~= "" and text or nil -- Remove locally if empty
                    net.Start("ixSetNickname") -- Persist change to server
                        net.WriteEntity(client)
                        net.WriteString(text)
                    net.SendToServer()
                end)
        end
    end

    -- Modify tooltips & chat to display custom nickname
    function PLUGIN:GetCharacterName(client)
        if client == LocalPlayer() then return client:GetCharacter():GetName() end
        return nicknameCache[client:GetCharacter():GetID()] or client:GetCharacter():GetName()
    end
end

---
--CHECK INVENTORY FUNCTION
---
ix.command.Add("charcheckinv", {
	adminOnly = true,
	arguments = {
		ix.type.character,
	},
	OnRun = function(self, client, character)
		if character then
			local target = character
			local inventory = target:GetInventory()
		
			if (target and target != client) then
				inventory:Sync(client)
				inventory:AddReceiver(client)
				
				netstream.Start(client, "invCheck", inventory:GetID())
	        elseif target == client then
	        	client:Notify("Can't check yourself")
	        else
	            client:Notify("Player not found")
	        end
	    end
	end
})

ix.command.Add("charcheckmoney", {
	adminOnly = true,
	arguments = {
		ix.type.character,
	},	
	OnRun = function(self, client, character)
		if character then
			local target = character
		
			if (target and target != client) then
				client:Notify("Target has "..ix.currency.Get(target:GetMoney()))
	        elseif target == client then
	        	client:Notify("Can't check yourself")
	        else
	            client:Notify("Player not found")
	        end
	    end
	end
})

if CLIENT then
	netstream.Hook("invCheck", function(index)
		local inventory = ix.item.inventories[index]

		if (inventory and inventory.slots) then
			
			local inventory2 = LocalPlayer():GetCharacter():GetInventory()
			
			if (inventory == inventory2) then
				return
			end
			
			ix.gui.inv1 = vgui.Create("ixInventory")
			ix.gui.inv1:ShowCloseButton(true)
			ix.gui.inv1:SetPos(ScrW()*0.5, ScrH()*0.2)

			

			if (inventory2) then
				ix.gui.inv1:SetInventory(inventory2)
			end

			local panel = vgui.Create("ixInventory")
			panel:ShowCloseButton(true)
			panel:SetTitle("Checked inventory")
			panel:SetInventory(inventory)
			panel:Center()
			panel:MoveLeftOf(ix.gui.inv1, 4)
			panel:MakePopup()
			panel.OnClose = function(this)
				if (IsValid(ix.gui.inv1) and !IsValid(ix.gui.menu)) then
					ix.gui.inv1:Remove()
				end

				netstream.Start("invCheckExit")
			end

			local oldClose = ix.gui.inv1.OnClose
			ix.gui.inv1.OnClose = function()
				if (IsValid(panel) and !IsValid(ix.gui.menu)) then
					panel:Remove()
				end

				netstream.Start("invCheckExit")
				-- IDK Why. Just make it sure to not glitch out with other stuffs.
				if ix.gui.inv1 then
					ix.gui.inv1.OnClose = oldClose
				end
			end

			ix.gui["inv"..index] = panel
		end
	end)
else
	netstream.Hook("invCheckExit", function(client)
		local entity = client.ixBagEntity

		if (IsValid(entity)) then
			entity.receivers[client] = nil
		end

		client.ixBagEntity = nil
	end)
end

if SERVER then 
    hook.Add("PlayerDeath", "StopSoundOnDeath", function(ply)
        if IsValid(ply) then
            ply:ConCommand("stopsound")
        end
    end)
end

--
--
--
-- Change name of world item you're looking at
ix.command.Add("SetItemName", {
    description = "Change the name of the world item you are looking at.",
    adminOnly = true,
    arguments = {ix.type.text},
    OnRun = function(self, client, newName)
        local ent = util.TraceLine({
            start = client:GetShootPos(),
            endpos = client:GetShootPos() + client:GetAimVector() * 96,
            filter = client
        }).Entity

        if not (IsValid(ent) and ent:GetClass() == "ix_item") then
            return "You're not looking at a valid item."
        end

        local item = ent:GetItemTable()
        if not item then return "Item table missing." end

        item:SetData("name", newName)       -- persistent override
        ent:SetNetVar("name", newName)      -- client display update

        client:Notify("Item name set to: " .. newName)
    end
})

-- Change description of world item you're looking at
ix.command.Add("SetItemDescription", {
    description = "Change the description of the world item you are looking at.",
    adminOnly = true,
    arguments = {ix.type.text},
    OnRun = function(self, client, newDesc)
        local tr = util.TraceLine({
            start = client:GetShootPos(),
            endpos = client:GetShootPos() + client:GetAimVector() * 96,
            filter = client
        })
        local ent = tr.Entity

        if not (IsValid(ent) and ent:GetClass() == "ix_item") then
            return "You're not looking at a valid world item."
        end

        local item = ent:GetItemTable()
        if not item then
            return "Failed to retrieve item table."
        end

        item:SetDescription(newDesc)
        client:Notify("Item description updated.")
    end
})
