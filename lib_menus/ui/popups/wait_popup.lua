local pluginName    = select(1,...);
local componentName = select(2,...);
local signalTable   = select(3,...);
local my_handle     = select(4,...);

-- *************************************************************
--
-- *************************************************************

signalTable.DoResetScreens = function(caller)
	Echo("Resetting screens. Please wait 10 seconds");
    coroutine.yield(1)

    if (HostOS() == "Linux") then

        local handle = io.popen("/usr/local/bin/rearrange_screens.sh -a");
		local result = handle:read("*a");
		handle:close();
		Echo(result);

        for i=5, 1, -1 do
            caller.Frame.InfoField.Text = string.format("Please wait %d seconds",i)
            coroutine.yield(1);
        end
	end

    CmdIndirect("ReloadUI");
end

