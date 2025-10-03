local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);


signalTable.SendIfIdleButtonLoaded = function(caller,status,creator)
	HookObjectChange(signalTable.OutputStationChanged, DeviceConfiguration().OutputStations, my_handle:Parent(), caller);
	signalTable.OutputStationChanged(nil, nil, caller)
end

signalTable.OutputStationChanged=function(signal, dummy, caller)
    local MyOutputStation = DeviceConfiguration().OutputStations.MyOutputStation;
	if (IsObjectValid(MyOutputStation) == true) then
		caller.Target = MyOutputStation
	end
end