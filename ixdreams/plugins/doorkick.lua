PLUGIN.name = "Doorkick"
PLUGIN.author = "Ayreborne"
PLUGIN.description = "Enhanced doorkick, self explanatory."

ix.command.Add("Doorkick", {
    description = "Kick the door.",
	OnRun = function(self, client)
		local entity = client:GetEyeTrace().Entity
		local current = client:GetLocalVar("ene", 0)

			if (IsValid(entity) and entity:IsDoor() and !entity:GetNetVar("disabled")) then
				if (client:GetPos():Distance(entity:GetPos())< 100) then	
					if(current > 90) then
						if(IsValid(entity.ixLock)) then
							client:Notify("You cannot kick down a combine lock!")
							return false
						end		

						client:ConsumeStamina(15)
						client:ForceSequence("adoorkick", nil, 1.5)
		
						timer.Simple( 0.5, function()		
							entity:Fire("unlock")
							entity:Fire("open")
						end)
					else
						client:Notify("You don't have enough stamina!")
					end
				else
					client:Notify("You are not close enough!")
				end
			else
				client:Notify("You are not looking at a door!")
			end	
    end
})