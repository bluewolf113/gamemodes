-- Add font for download
resource.AddFile( "resource/fonts/ibmfont.ttf" )

-- Hook name change to update it on serverside;
ix.char.HookVar("name", "ix.datapad.hook.var.name", function(targetCharacter, prevName, newName)
    if prevName == newName then
        return;
    end;

    local characterID = targetCharacter:GetID();
    local archived = ix.archive.Get(characterID)
    if archived then
        archived:SetName(newName)
    end;
end)

if SERVER then
    util.AddNetworkString("ixOpenDatapad")

    net.Receive("ixOpenDatapad", function(len, client)
        if not IsValid(client) or not client:GetCharacter() then
            client:Notify("Invalid player or character!")
            return
        end

        -- Set persona and open datapad
        client:SetLocalVar("_persona", ix.archive.police.New({
            id = client:GetCharacter():GetID(),
            name = "SUPERADMIN",
            rank = "i4"
        }))

        ix.datapad.Open(client, true)
    end)
end