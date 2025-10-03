local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.SetTargetMsgBox = function(caller,status)
	local overlay = caller:GetOverlay();
	if (overlay) then
		caller.Target = overlay;
	end
end

signalTable.CommandClicked = function(caller,val)
	local overlay = caller:GetOverlay();
	if (overlay) then
		overlay.CueStoreOp = val
		overlay.Close()
	end
end

signalTable.LoadPrefClicked = function(caller,status)
	local overlay = caller:GetOverlay();
	if (overlay) then
		local Preferences=CurrentProfile().StorePreferences;
		local temp    =overlay;
		temp.CueOnly          = Preferences.CueOnly;
		temp.TrackingShield   = Preferences.TrackingShield;
	end
end

signalTable.SavePrefClicked = function(caller,status)
	local overlay = caller:GetOverlay();
	if (overlay) then
		local Preferences=CurrentProfile().StorePreferences;
		local temp    =overlay;
		Preferences.CueOnly          = temp.CueOnly;
		Preferences.TrackingShield   = temp.TrackingShield;
	end
end



