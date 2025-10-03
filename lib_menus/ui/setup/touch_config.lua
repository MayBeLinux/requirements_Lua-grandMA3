local pluginName    = select(1,...);
local componentName = select(2,...);
local signalTable   = select(3,...);
local my_handle     = select(4,...);

-- *************************************************************
--
-- *************************************************************

signalTable.DoResetScreens11 = function(caller)
	Echo("Resetting screens");
	if (HostOS() == "Linux") then
		-- MessageBox({title = "Resetting screens", message = "Please wait for resetting of screen positions", display = caller:GetDisplayIndex(), commands={{value = 1, name = "Ok"}}});

		local handle = io.popen("/usr/local/bin/rearrange_screens.sh -a");
		local result = handle:read("*a");
		handle:close();
		Echo(result);
		coroutine.yield(5);
	end

    CmdIndirect("ReloadUI");
end
