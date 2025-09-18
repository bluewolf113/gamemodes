net.Receive("MagazineReloaded", function()
    local msg = net.ReadString()
    chat.AddText(Color(0, 255, 0), "[Magazine System] " .. msg)
end)
