ITEM.name = "Box"
ITEM.description = "A Box."
ITEM.model = "models/props_junk/cardboard_box003a.mdl" -- Example model for a bag
ITEM.isSealed = false
ITEM.isBomb = false

function ITEM:GetName()
    return self:GetData("sealed", false) and "Sealed " .. self.name or self.name
end

ITEM.functions.combine = {
    OnRun = function(item, data)
        local other = ix.item.instances[data[1]]
        if not other then return false end

        local ply = item.player
        if not IsValid(ply) then return false end

        local index  = item:GetData("id", "")
        local pos    = ply:GetPos()
        local sealed = item:GetData("sealed", false)
        local bombed = item:GetData("isBomb", false)

        local function closePanel()
            hook.Run("OnBagDropped", index)
        end

        local function explode()
            ix.chat.Send(ply, "localevent",
                "The box is cut open... and something inside detonates.",
                nil, nil, {range = 500}
            )
            ply:EmitSound("phx/hmetal1.wav", 50)

            timer.Simple(3, function()
                if not IsValid(ply) then return end

                local explosion = ents.Create("env_explosion")
                explosion:SetPos(pos)
                explosion:SetOwner(ply)
                explosion:Spawn()
                explosion:SetKeyValue("iMagnitude", "250")
                explosion:Fire("Explode", 0, 0)

                local inv  = ply:GetCharacter():GetInventory()
                local inst = inv and inv:GetItemByID(item:GetID())
                if inst then inst:Remove() end
            end)
        end

        -- ✅ Taping: 3-second action before sealing
        if other.uniqueID == "tapeduct" and not sealed then
            if SERVER then
                -- Cache original movement speeds
                local origWalk = ply:GetWalkSpeed()
                local origRun  = ply:GetRunSpeed()

                -- Lock movement but allow looking
                ply:SetWalkSpeed(0)
                ply:SetRunSpeed(0)

                ply:SetAction("Taping", 3, function()
                    -- Restore movement
                    ply:SetWalkSpeed(origWalk)
                    ply:SetRunSpeed(origRun)

                    item:SetData("sealed", true)
                    other:Remove()
                    ply:EmitSound("physics/flesh/flesh_squishy_impact_hard4.wav", 40, 100)

                    local index = item:GetData("id", "")
                    hook.Run("OnBagDropped", index)
                end)
            end
        end

        -- Optional: restore movement if interrupted early
        timer.Simple(3, function()
            if IsValid(ply) then
                ply:SetWalkSpeed(origWalk)
                ply:SetRunSpeed(origRun)
            end
        end)
        -- ✅ Cutting: 3-second action before unsealing or exploding
        elseif other.uniqueID == "bowieknife" and sealed then
            if SERVER then
                ply:SetAction("Cutting Open", 2, function()
                    item:SetData("sealed", false)
                    if item:GetData("isBomb", false) then
                        explode()
                    else
                        ply:EmitSound("physics/flesh/flesh_squishy_impact_hard4.wav", 40, 100)
                        closePanel()
                    end
                end)
            end
        end

        -- ✅ Arming bomb instantly
        elseif other.uniqueID == "testexplosion" and not bombed then
            item:SetData("isBomb", true)
            other:Remove()
            ply:EmitSound("buttons/button17.wav", 50, 100)
        end

        return false
    end
    }
    OnCanRun = function(item, data)
        local other = ix.item.instances[data[1]]
        if not other then return false end

        local sealed = item:GetData("sealed", false)
        local bombed = item:GetData("isBomb", false)

        return (other.uniqueID == "tapeduct"     and not sealed)
            or (other.uniqueID == "bowieknife"   and sealed)
            or (other.uniqueID == "testexplosion" and not bombed)
    end
}



if (CLIENT) then
    hook.Add("OnBagDropped", "CloseBagPanel", function(index)
        local panel = ix.gui["inv" .. index]
        if IsValid(panel) and panel:IsVisible() then
            panel:Close()
        end
    end)

    net.Receive("ixBagDrop", function()
        local index = net.ReadUInt(32)
        hook.Run("OnBagDropped", index)
    end)
end

ITEM.functions.View = {
	icon = "icon16/briefcase.png",
	OnClick = function(item)
		local index = item:GetData("id", "")

		if (index) then
			local panel = ix.gui["inv"..index]
			local inventory = ix.item.inventories[index]
			local parent = IsValid(ix.gui.menuInventoryContainer) and ix.gui.menuInventoryContainer or ix.gui.openedStorage

			if (IsValid(panel)) then
				panel:Remove()
			end

			if (inventory and inventory.slots) then
				panel = vgui.Create("ixInventory", IsValid(parent) and parent or nil)
				panel:SetInventory(inventory)
				panel:ShowCloseButton(true)
				panel:SetTitle(item.GetName and item:GetName() or L(item.name))

				if (parent != ix.gui.menuInventoryContainer) then
					panel:Center()

					if (parent == ix.gui.openedStorage) then
						panel:MakePopup()
					end
				else
					panel:MoveToFront()
				end

				ix.gui["inv"..index] = panel
			else
				ErrorNoHalt("[Helix] Attempt to view an uninitialized inventory '"..index.."'\n")
			end
		end

		return false
	end,
    OnCanRun = function(item)
        return not item:GetData("sealed", false)
            and not IsValid(item.entity)
            and item:GetData("id")
            and not IsValid(ix.gui["inv" .. item:GetData("id", "")])
    end
}

ITEM.functions.Open = {
    icon = "icon16/lock_open.png",

    OnRun = function(item)
        local client = item and item.player
        if not IsValid(client) then return false end

        local character = client:GetCharacter()
        if not character then return false end

        local isBomb    = item:GetData("isBomb", false)
        local openTime  = 6
        local pos       = client:GetPos()
        local itemID    = item:GetID()

        if SERVER then
            -- Cache original movement speeds
            local origWalk = client:GetWalkSpeed()
            local origRun  = client:GetRunSpeed()

            -- Restrict movement but allow looking
            client:SetWalkSpeed(15)
            client:SetRunSpeed(0)

            -- Start stared action (handles progress bar)
            client:DoStaredAction(item, function()
                if not IsValid(client) then return end

                -- Restore movement speeds
                client:SetWalkSpeed(origWalk)
                client:SetRunSpeed(origRun)

                -- Validate item still exists
                local inv  = character:GetInventory()
                local inst = inv and inv:GetItemByID(itemID)
                if not inst then return end

                if isBomb then
                    -- Bomb trigger
                    ix.chat.Send(client, "localevent", "As you finish opening it... something inside detonates.", nil, nil, {range = 500})
                    client:EmitSound("phx/hmetal1.wav", 50)

                    timer.Simple(3, function()
                        if not IsValid(client) then return end
                        local explosion = ents.Create("env_explosion")
                        explosion:SetPos(pos)
                        explosion:SetOwner(client)
                        explosion:Spawn()
                        explosion:SetKeyValue("iMagnitude", "250")
                        explosion:Fire("Explode", 0, 0)

                        if IsValid(inst) then
                            inst:Remove()
                        end
                    end)
                else
                    -- Normal unseal
                    inst:SetData("sealed", false)
                    client:EmitSound(item.openSound or "items/ammopickup.wav", 60, 100)
                end
            end, openTime, function()
                -- Cancel callback: restore movement if interrupted
                client:SetWalkSpeed(origWalk)
                client:SetRunSpeed(origRun)
            end)
        end

        return false
    end,

    OnCanRun = function(item)
        return item:GetData("sealed", false) == true
    end
}



