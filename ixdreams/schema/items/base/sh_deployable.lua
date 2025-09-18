ix.item.deployedEntities = ix.item.deployedEntities or {}

ITEM.name = "Deployable Base"
ITEM.model = "models/combine_helicopter/helicopter_bomb01.mdl"
ITEM.category = "Equipment"
ITEM.description = "A base for deployable equipment."
-- ITEM.bCanRetrieve = true

function ITEM:GetMessages()
	local messages = {}
	
	messages["Deploy"] = self.deployText
	messages["Retrieve"] = self.retrieveText
	messages.delay = self.messageDelay or 12
	
	return messages
end

ITEM.functions.Deploy = {
	OnRun = function(item)
			local ent = ents.Create(item.className or "sent_ball")
			local client = item.player
			
			-- initialize with OnEntityDeployed or spawn at cursor location

			if (item.OnEntityDeployed) then
				item:OnEntityDeployed(ent)
			else
				deployPos = item.deployPos or client:GetItemDropPos(ent)
				deployAngles = item.deployAngles or Angle(0, client:EyeAngles().yaw, 0)
				
				ent:SetPos(deployPos)
				ent:SetAngles(deployAngles)
				ent:Spawn()
				
				ix.item.deployedEntities[ent] = item:GetID()
				
				if item.bGroundEntity then 
					ent:DropToFloor() 
				end
			end
			
			if item.bCanRetrieve then
				ent:SetNetVar("ixDeployedItemID", item:GetID())
			end
			
			if item.deployText then
				ply:ChatNotify(item.deployText)
			end
			
			if item.bCanRetrieve then
				-- if the item is retrievable, we don't want to delete it. transfer it to the world logically. this allows us to retrieve deployed equipment without destroying and recreating the item
				item:Transfer(nil, nil, nil, client, false, true)
				return false
			end
			
		return true
	end,
	
	OnCanRun = function(item)
		return item.CanPlayerDeploy and item:CanPlayerDeploy() or true
	end
}

ITEM:Hook("OnRegistered", "SetupDeployableFunction", function(item, data)
	if item.functions.Deploy and not item.isBase then
		item.functions.Deploy.name = item.DeployText or "Deploy"
		item.functions.Deploy.icon = item.DeployIcon or "icon16/cog.png"
	end	
end)

-- create a menu for retrieval if we press E on an entity that was deployed from an item, i.e. has a networked string var "ixDeployedItemID"

if SERVER then

	util.AddNetworkString("ixRetrieveDeployable")
	util.AddNetworkString("ixOpenDeployableMenu")

	net.Receive("ixRetrieveDeployable", function()
			local ply = net.ReadPlayer()
			local ent = net.ReadEntity()
			
			if not IsValid(ply) or not IsValid(ent) then return end
			
			local character = ply:GetCharacter()
			
			if not character then return end
			
			local charInv = character:GetInventory()	
			local invID = charInv:GetID()
			local itemID = ent:GetNetVar("ixDeployedItemID", -1)
			
			-- todo: - figure out why Spawn() doesn't do anything
			-- 		 - make item spawn at location if inventory full
			
			if itemID != -1 then				
				local item = ix.item.instances[itemID]
				local bPlyCanRetrieve = (item.CanPlayerRetrieve and item:CanPlayerRetrieve(ply, ent)) or true		
				
				if bPlyCanRetrieve then
				
					if not item:Transfer(invID, nil, nil, ply) then
						ply:NotifyLocalized("noFit")
						
						local itemEntity = item:Spawn(ply)
						itemEntity.ixItemID = itemID

						local physicsObject = itemEntity:GetPhysicsObject()

						if (IsValid(physicsObject)) then
							physicsObject:EnableMotion(true)
						end
						
						print("ixRetrieveDeployable: IsValid(itemEntity) = " .. tostring(IsValid(itemEntity)))
						print("ixRetrieveDeployable: itemEntity:GetPos() = " .. tostring(itemEntity:GetPos()))
						
						itemEntity:SetPos(ply:GetPos())
					end
					
					
				
					-- local bSuccess = item:Transfer(invID, nil, nil, ply)
					
					-- if not bSuccess then	
						-- item:Spawn(ply)
					-- end

					if item.retrieveText then
						ply:ChatNotify(item.retrieveText)
					end
					
					local bRemoveEnt = (item.OnRetrieve and item:OnRetrieve(ply, ent)) or true
					
					if bRemoveEnt then
						ix.item.deployedEntities[ent] = nil
						ent:Remove()
					end
				end
			end
		end)	
end

if CLIENT then
	net.Receive("ixOpenDeployableMenu", function()
		local ent = net.ReadEntity()
		if not IsValid(ent) or IsValid(ix.gui.itemRetrievalMenu) then return end

		ix.gui.itemRetrievalMenu = vgui.Create("DFrame")
		ix.gui.itemRetrievalMenu:SetSize(300, 150)
		ix.gui.itemRetrievalMenu:Center()
		ix.gui.itemRetrievalMenu:SetTitle("Deployable Interaction")
		ix.gui.itemRetrievalMenu:MakePopup()

		local btn = vgui.Create("DButton", ix.gui.itemRetrievalMenu)
		btn:SetText("Retrieve Equipment")
		btn:Dock(BOTTOM)
		btn:DockMargin(10, 10, 10, 10)
		btn.DoClick = function()
			net.Start("ixRetrieveDeployable")
				net.WritePlayer(LocalPlayer())
				net.WriteEntity(ent)
			net.SendToServer()
			ix.gui.itemRetrievalMenu:Close()
		end
	end)
end

if SERVER then

	hook.Add("KeyRelease", "ixDeployableUse", function(client, key)
		if key == IN_USE then
			local data = {}
			data.start = client:GetShootPos()
			data.endpos = data.start + client:GetAimVector() * 96
			data.filter = client
				
			local ent = util.TraceLine(data).Entity
			
			if IsValid(ent) and ent:GetNetVar("ixDeployedItemID", -1) ~= -1 then		
				net.Start("ixOpenDeployableMenu")
				net.WriteEntity(ent)
				net.Send(client)
			end	
		end
	end)

	hook.Add("EntityRemoved", "ixDeployableEntityRemoved", function(ent)
		if IsValid(ent) and ent:GetNetVar("ixDeployedItemID", -1) ~= -1 then
			local itemID = ent:GetNetVar("ixDeployedItemID")
			local item = ix.item.instances[itemID]
			
			if not item:GetOwner() and not item.bNoDelete then
				item:Remove()
			end
		end
	end)

end