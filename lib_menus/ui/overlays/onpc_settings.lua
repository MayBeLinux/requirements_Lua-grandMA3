local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.OnPCSettingsLoaded = function(caller,status,creator)
	if (caller:WaitInit(1) ~= true) then
		ErrEcho("Failed to wait");
		return;
	end
	caller.Frame.Settings.BtnMouseCursorSize.Visible = HostType() == "Console"
end


signalTable.OnResetTimeToSystemTime = function(caller,status,creator)
    local status = Root().ManetSocket.Status;
    if status == "Connected" then
        MessageBox({title = "Information", message = "Resetting to system time is not possible while connected.", display = caller:GetDisplayIndex(), commands={{value = 1, name = "Ok"}}});
    else
	    Echo("Resetting time to system time");
		local MilliSecondsPerHour = (1000 * 60 * 60);
		local daylightGma = 0;
        if Root().StationSettings.TimeConfig.DaylightSavingState == 1 then
            daylightGma = MilliSecondsPerHour;
        end

		local now = os.time()
        local t = os.date("*t", now)
		local daylightSys = 0;
		if t.isdst then
		    daylightSys = MilliSecondsPerHour;
		end

	    local LocalTimeOffset = (os.time(os.date("*t")) * 1000) - (os.time(os.date("!*t")) * 1000);
		local ResultTimeOffset = LocalTimeOffset + daylightSys - daylightGma - (Root().StationSettings.TimeConfig.Timezone * MilliSecondsPerHour);
		Root().StationSettings.TimeConfig.OnPCSystemTimeOffset = ResultTimeOffset

        --Echo("ResultTimeOffset "..ResultTimeOffset);		

	end
end

signalTable.StartupshowfileEdit = function(caller, status, creator)
	CmdIndirect("Menu 'Startupshow'");
end
