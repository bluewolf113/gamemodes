
local PLUGIN = PLUGIN

net.Receive("ixRadio.registerChannel", function(len)
	ix.radio.RegisterChannel(net.ReadString(), {})
end)