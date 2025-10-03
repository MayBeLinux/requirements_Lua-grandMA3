local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);


signalTable.OnLoaded = function(caller,status,creator)
	HookObjectChange(signalTable.BatteryStatusChanged,Root().HardwareStatus.BatteryStatus,my_handle:Parent(), caller);
end

signalTable.SaveAndShutdown = function()
	Cmd("SaveShow");
	Cmd("ShutDown /nc");
end

signalTable.ChangeMessage = function(caller)
	local BatteryStatus=Root().HardwareStatus.BatteryStatus;
	local SaveShowTime = nil;
	local content = caller:Parent()
	local progbar = content.Progress
	while (caller.Text ~= nil) and (not BatteryStatus.AcPowerOk) do
		local WarningLevel = BatteryStatus.WarningLevel;
		-- WarningLevel 1 -> 50%, 2 -> 25%
		if(WarningLevel >= 2) then
			caller.Text = string.format("The battery power is low (%.0f%%).\nSave the show file immediately and shut down the console!", BatteryStatus.BattPercentage);
		else
			caller.Text = string.format("The console is now running on battery power (%.0f%%).\nCheck the power source!", BatteryStatus.BattPercentage);
		end
		
		if WarningLevel >= 1 then
			if NeedShowSave() then
				if not SaveShowTime then
					SaveShowTime = Time() + 60
				end
				
				local CountdownSecondsF = SaveShowTime - Time()
				local CountdownSecondsI = math.floor(CountdownSecondsF)
	
				progbar.visible = true;
				progbar.progress = 1 - CountdownSecondsI / 60
				progbar.BarText = string.format("Saving show file in %d seconds.", CountdownSecondsI)
	
				if CountdownSecondsF < 0 then
					CmdIndirect("Saveshow")
					progbar.visible = false;
				end
			else
				progbar.visible = false;
			end
		end

		coroutine.yield(1)
	end
end

signalTable.BatteryStatusChanged = function(BatteryStatus,status,creator)	
	if(BatteryStatus.AcPowerOk) then
		creator.close();
	end


end