ITEM.name = "Buggy"
ITEM.description = "A stripped-down jalopy shell. It has no parts installed."
ITEM.model = "models/buggy.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.category = "Vehicles"

function ITEM:CanPickup(client, entity)
    return false
end


-- Helper to safely get part data
local function GetCarData(item)
    return item:GetData(nil, {
        battery   = false
    })
end

-- Install Battery
ITEM.functions.InstallBattery = {
    name = "Install Battery",
    icon = "icon16/cog.png",
    OnCanRun = function(item)
        local client = item.player
        if not IsValid(client) then return false end

        local d = GetCarData(item)
        if d.battery then return false end

        return client:GetCharacter():GetInventory():HasItem("carbattery")
    end,
    OnRun = function(item)
        local client = item.player
        if not IsValid(client) then return false end

        client:SetAction("Installing Battery...", 10, function()
            local inv = client:GetCharacter():GetInventory()
            local batteryItem = inv:HasItem("carbattery")

            if batteryItem and not item:GetData("battery", false) then
                batteryItem:Remove()
                item:SetData("battery", true)
                client:Notify("You installed the car battery into the jalopy.")
            else
                client:Notify("Installation failed. Missing battery.")
            end
        end)
        return false
    end
}

-- Finish Vehicle
ITEM.functions.FinishVehicle = {
    name = "Finish Vehicle",
    icon = "icon16/car.png",
    OnCanRun = function(item)
        local d = GetCarData(item)

        return (
            d.battery
        )
    end,
    OnRun = function(item)
        local client = item.player
        if not IsValid(client) then return false end

        local ent = item.entity
        local pos, ang

        if IsValid(ent) then
            pos = ent:GetPos() + Vector(0, 0, 10)
            ang = ent:GetAngles()
            ent:Remove()
        else
            pos = client:GetPos() + client:GetForward() * 100
            ang = client:EyeAngles()
            item:Remove()
        end

        local vehicle = ents.Create("prop_vehicle_jeep")
        if IsValid(vehicle) then
            vehicle:SetModel("models/buggy.mdl")
            vehicle:SetKeyValue("vehiclescript", "scripts/vehicles/jeep_test.txt")
            vehicle:SetPos(pos)
            vehicle:SetAngles(ang)
            vehicle:Spawn()
            vehicle:Activate()

            client:Notify("You’ve finished assembling the jalopy into a working Jeep!")
        else
            client:Notify("Failed to spawn vehicle.")
        end

        return false
    end
}