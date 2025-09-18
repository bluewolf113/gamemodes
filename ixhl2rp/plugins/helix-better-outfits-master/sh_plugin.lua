local PLUGIN = PLUGIN
PLUGIN.name = "Helios Outfits"
PLUGIN.author = "Helios"
PLUGIN.desc = "Fixes some issues with Helix's builtin outfit system."

if SERVER then
    timer.Create("UniversalClothingDirty", 5, 0, function()
        for _, client in ipairs(player.GetAll()) do
            if not IsValid(client) then continue end
            local char = client:GetCharacter()
            if not char then continue end

            local inv = char:GetInventory()
            for _, item in pairs(inv:GetItems()) do
                if not item.bClothing then continue end        -- only clothing
                if not item:GetData("equip", false) then continue end

                local cur = item:GetData("cleanliness", 0)
                if cur >= item.maxCleanliness then continue end

                local nxt = math.min(cur + 5, item.maxCleanliness)
                item:SetData("cleanliness", nxt)

                if nxt >= item.maxCleanliness then
                    client:Notify("Your outfit is now fully dirty!")
                end
            end
        end
    end)
end