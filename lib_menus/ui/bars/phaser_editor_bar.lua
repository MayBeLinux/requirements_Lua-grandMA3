local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local g_EncoderList = {"Encoder1a", "Encoder1b", "Encoder2a", "Encoder2b","Encoder3a","Encoder3b","Encoder4"};
-- --------------------------------------------------------
--
-- --------------------------------------------------------

signalTable.LinkedWindowChanged = function(caller,status,context)
	caller.LinkedObject=context;
	local PLG;
	if(context:GetClass() == "PhaserLayoutGrid") then
		PLG = context;
	else
		local window = signalTable.GetWindowOrOverlay(context);
		if(window ~= nil) then
			PLG = window.PhaserLayoutGrid;
		end
	end
	caller.Options.Pages.Target=caller;
	if(PLG ~= nil) then
		caller.Lower:SetChildren("Target",PLG);
	end

	UnhookMultiple(signalTable.SettingsChanged);
	local settings = signalTable.GetSettings(PLG);
	if(settings ~= nil) then
		HookObjectChange(signalTable.SettingsChanged,settings,my_handle:Parent(),caller);
		signalTable.SettingsChanged(settings, nil, caller)
	end
end

-- --------------------------------------------------------
--
-- --------------------------------------------------------

signalTable.GetWindowOrOverlay = function(caller)
	local window = caller:GetOverlay()
	if (window == nil) then
		window = caller:FindParent("Window");
	end

	return window;

end

signalTable.GetSettings = function(caller)	
	local settings = nil;
	if(caller ~= nil) then
		local window = caller:FindParent("Window");
		if (window ~= nil) then
			settings = window.WindowSettings;
		else
			settings = CurrentProfile().TemporaryWindowSettings.WindowPhaserEditorSettings;
		end
	end
	return settings;

end

-- --------------------------------------------------------
--
-- --------------------------------------------------------
signalTable.SettingsChanged = function(settings, dummy, caller)
	for ii = 1,#g_EncoderList do
		local encoderBtn = caller.Lower[g_EncoderList[ii]];
		if(encoderBtn ~= nil) then
			if(settings.AbsRelMode == "Abs+Rel") then
				encoderBtn.ColorIndicator="EncoderBar.MultiStep"
			else
				encoderBtn.ColorIndicator="ProgLayer." .. settings.AbsRelMode;
			end
		end
	end
end

-- --------------------------------------------------------
--
-- --------------------------------------------------------

signalTable.EncoderPageChanged = function(caller,status,window)
	Echo("Encoder-page changed")
end