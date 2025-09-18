ITEM.base = "base_drink"

ITEM.name = "Tea"
ITEM.model = Model("models/props_junk/garbage_coffeemug001a.mdl")
ITEM.width = 1
ITEM.height = 1
ITEM.description = "A %s cup of tea."
ITEM.drink = "Nothing like a good cuppa."
ITEM.category = "Drink"
ITEM.thirst = 10
ITEM.uses = 8
ITEM.junk = {["emptycup1"] =  1}

function ITEM:OnEntityCreated()
	local temperature = self:GetData("temperature", 0)
	self:SetData("temperature", temperature)
	
	if temperature < 1 then	
		timer.Create("ixItemTemperatureWarm_" .. self:GetID(), 180, 1, function() 
			self:SetData("temperature", 1)
		end)
	end
	
	if temperature < 2 then
		timer.Create("ixItemTemperatureCold_" .. self:GetID(), 360, 1, function() 
			self:SetData("temperature", 2)
		end)
	end
end

function ITEM:GetDescription()
	local temperature = self:GetData("temperature", 0)
	local temperatureText = (temperature == 0 and "hot") or (temperature == 1 and "warm") or "cold"
	return string.format(self.description, temperatureText)
end

