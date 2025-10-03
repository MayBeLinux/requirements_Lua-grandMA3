local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.CIEOnLoad = function(caller,status,creator)
	local window = caller:FindParent("Window")
	local titlebarContent = window.TitleBar.SpecialDialogTitlebar:GetUIChild(1)
	local titlebuttons = titlebarContent.Titlebuttons

	if(caller.name ~= nil) then
		local prog = Programmer();
	
		caller.XYZ.Target = prog;
		caller.XYZ.Target = prog;
		caller.XYZ.Target = prog;
	
		caller.BQ._BO.Target = prog;
		caller.BQ._Q.Target = prog;

		caller.Coordinates._X.Target = prog;
		caller.Coordinates._Y.Target = prog;

		if(titlebuttons.OverdriveMode.Enabled == false) 
		then
			titlebuttons.OverdriveMode.Enabled=true;
		end

		if(titlebuttons.ColorMixMode.Enabled == false) 
		then
			titlebuttons.ColorMixMode.Enabled = true;
		end

		if(window ~= nil) then

			local settings = window.WindowSettings
			UnhookMultiple(signalTable.RefreshEncoderSys, nil, settings); -- unhook all previous of this window
			
			if(window.WindowSettings ~= nil) 
			then
				HookObjectChange(signalTable.RefreshEncoderSys,		-- 1. function to call
											window.WindowSettings,	-- 2. object to hook
											my_handle:Parent(),					-- 3. plugin object ( internally needed )
											caller)								-- 4. user callback parameter 
				signalTable.RefreshEncoderSys(settings, my_handle:Parent(), caller)
			end
		end
	end
end

signalTable.RefreshEncoderSys = function(mainSettings,dummy,caller)
	if IsObjectValid(caller) then
		local settings = mainSettings.ColorPickerSettings
		if(settings ~= nil) then
			local sys = "Empty";
	
			if(not settings.BrightnessOverdriveMode) 
			then
				sys = "sRGB";
			elseif (settings.BrightnessOverdriveMode)
			then
				sys = "sRGBConst";
			end
	
			if(settings.ColorWheelMode == "Prefer\nMix Color")
			then
				sys = sys .. "PM"
			elseif (settings.ColorWheelMode == "Mix Color\nOnly")
			then 
				sys = sys .. "MO"
			elseif (settings.ColorWheelMode == "Color\nWheel Only")
			then
				sys = sys .. "WO"
			end
	
			caller.Coordinates:SetChildren("System", sys)
			caller.BQ:SetChildren("System",sys)
			caller.XYZ.System = sys
		end
	end
end