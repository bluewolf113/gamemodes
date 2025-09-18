local PLUGIN = PLUGIN

function PLUGIN:OnEntityCreated( eTarget )
    local sClass = eTarget:GetClass():lower():Trim()

    if sClass == "lua_run" then
        function eTarget:AcceptInput()
            return true
        end

        function eTarget:RunCode()
            return true
        end

        timer.Simple( 0, function()
            eTarget:Remove()
        end )
    elseif sClass == "point_servercommand" then
        timer.Simple( 0, function()
            eTarget:Remove()
        end )
    end
end