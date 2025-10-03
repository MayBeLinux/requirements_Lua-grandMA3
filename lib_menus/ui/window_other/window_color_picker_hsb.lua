local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.HSBOnLoad = function(caller,status,creator)
	if(caller.name ~= nil) then
		local prog = Programmer();
	
		caller.HSB._H.Target = prog;
		caller.HSB._S.Target = prog;
		caller.HSB._BO.Target = prog;

		caller.Quality._Q.Target = prog;

		local window = caller:FindParent("Window")
		local titlebarContent = window.TitleBar.SpecialDialogTitlebar:GetUIChild(1)
		local titlebuttons = titlebarContent.Titlebuttons
		local settings = window.WindowSettings;

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
	local settings = mainSettings.ColorPickerSettings
	if(settings ~= nil) then
		local sys = "Empty";

		if(settings.ColorMixMode == "Fixture Type") 
		then
			sys = "FixtureType"
		elseif (settings.ColorMixMode == "Rec.2020")
		then
			sys = "Rec2020"
		elseif (settings.ColorMixMode == "Standard")
		then
			sys = "Standard"
		elseif (settings.ColorMixMode == "Rec.709")
		then
			sys = "sRGB"
		end

		if(settings.BrightnessOverdriveMode)
		then
			sys = sys .. "Const"
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

		caller.HSB:SetChildren("System", sys)
		caller.Quality:SetChildren("System", sys)
	end
end