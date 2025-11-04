local PLUGIN = PLUGIN
PLUGIN.name = "Books"
PLUGIN.author = "Subleader and Blue Wolf"
PLUGIN.desc = "Adds readable books."
PAPERLIMIT = 10000

if CLIENT then
    netstream.Hook("receiveBook", function(id, pages)
        local paper = vgui.Create("bookRead")
        paper:setText(pages, id)
    end)
else
    netstream.Hook("bookSendText", function(client, id, pages)
        local char = client:GetCharacter()
        if not char then return end

        local inv = char:GetInventory()
        for _, item in pairs(inv:GetItems()) do
            if item:GetID() == id then
                item:SetData("BookData", pages)
            end
        end

        for _, ent in ipairs(ents.GetAll()) do
            if ent:GetClass() == "ix_item" and ent.ixItemID == id then
                local item = ix.item.instances[id]
                if item then
                    item:SetData("BookData", pages)
                end
            end
        end
    end)
end
