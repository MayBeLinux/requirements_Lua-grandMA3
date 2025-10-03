local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local FocusedColorWindow = nil;
		
-- --------------------------------------------------------
--
-- --------------------------------------------------------

signalTable.BarLoaded = function(caller,status,window)

	local prog = Programmer();

	caller.Lower.Encoder1.Target=prog;
    caller.Lower.Encoder2.Target=prog;
    caller.Lower.Encoder3.Target=prog;
    caller.Lower.Encoder4.Target=prog;
	caller.Upper.Mode.Target=caller;

	if(window:GetClass() == "SpecialWindow") then
		caller.LinkedObject = window
	end
	FocusedColorWindow = caller.LinkedObject

	if(FocusedColorWindow ~= nil) then

		local settings = FocusedColorWindow.WindowSettings
		UnhookMultiple(signalTable.RefreshEncoderPage, nil, caller);

		if(FocusedColorWindow.WindowSettings ~= nil) 
		then
			caller.Upper.OverdriveMode.Target = settings.ColorPickerSettings;
			caller.Upper.ColorMixMode.Target = settings.ColorPickerSettings;
			caller.ColorEncoderFunction = settings.ColorPickerSettings.LastColorEncoderFunction
			
			HookObjectChange(signalTable.RefreshEncoderPage,		-- 1. function to call
										FocusedColorWindow.WindowSettings,	-- 2. object to hook
										my_handle:Parent(),					-- 3. plugin object ( internally needed )
										caller)								-- 4. user callback parameter 
			signalTable.RefreshEncoderPage(settings, my_handle:Parent(), caller)
		end
	end
end

-- --------------------------------------------------------
--
-- --------------------------------------------------------
signalTable.RefreshEncoderPage = function(WindowSettings,dummy,EncoderBarObj)
	if(FocusedColorWindow ~= nil and FocusedColorWindow.WindowSettings ~= nil) then
		local settings = WindowSettings.ColorPickerSettings;
		local Lower=EncoderBarObj.Lower;

		if (EncoderBarObj.ColorEncoderFunction=="Auto")
		then
			if(settings.Mode == "CIE")
			then
				Lower.Encoder1.Property = "x"
				Lower.Encoder2.Property = "y"
				Lower.Encoder3.Property = "BO"
				Lower.Encoder4.Property = "Q"
			elseif(settings.Mode == "HSB")
			then
				Lower.Encoder1.Property = "H"
				Lower.Encoder2.Property = "S"
				Lower.Encoder3.Property = "BO"
				Lower.Encoder4.Property = "Q"
			elseif(settings.Mode == "Fader")
			then
				Lower.Encoder1.Property = "R"
				Lower.Encoder2.Property = "G"
				Lower.Encoder3.Property = "B"
				Lower.Encoder4.Property = "Q"
			end
		elseif (EncoderBarObj.ColorEncoderFunction=="HSB")
		then
			Lower.Encoder1.Property = "H"
			Lower.Encoder2.Property = "S"
			Lower.Encoder3.Property = "BO"
			Lower.Encoder4.Property = "Q"
		elseif (EncoderBarObj.ColorEncoderFunction=="RGB")
		then
			Lower.Encoder1.Property = "R"
			Lower.Encoder2.Property = "G"
			Lower.Encoder3.Property = "B"
			Lower.Encoder4.Property = "Q"
		elseif (EncoderBarObj.ColorEncoderFunction=="CMY")
		then
			Lower.Encoder1.Property = "C"
			Lower.Encoder2.Property = "M"
			Lower.Encoder3.Property = "Y"
			Lower.Encoder4.Property = "Q"
		elseif (EncoderBarObj.ColorEncoderFunction=="CIE")
		then
			Lower.Encoder1.Property = "x"
			Lower.Encoder2.Property = "y"
			Lower.Encoder3.Property = "BO"
			Lower.Encoder4.Property = "Q"
		end


		local sys = "Empty";
		if(Lower.Encoder1.Property == "x") -- CIE Picker is always working in sRGB Mode
		then
			sys = "sRGB"
		else
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
		end
		if(settings.BrightnessOverdriveMode)
		then
			sys = sys .. "Const"
		end

		sys = sys .."Rel"

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

		Lower.Encoder1.System = sys
		Lower.Encoder2.System = sys
		Lower.Encoder3.System = sys
		Lower.Encoder4.System = sys


		
	end
end

signalTable.EncoderModeChanged = function(PageButton,dummy,ButtonValue)
	local EncoderBarObj = PageButton:Parent():Parent()
	FocusedColorWindow = EncoderBarObj.LinkedObject

	if(FocusedColorWindow ~= nil and EncoderBarObj ~= nil) then

		local settings = FocusedColorWindow.WindowSettings.ColorPickerSettings
		settings.LastColorEncoderFunction = EncoderBarObj.ColorEncoderFunction

		if(FocusedColorWindow.WindowSettings ~= nil) then
			signalTable.RefreshEncoderPage(settings, my_handle:Parent(), EncoderBarObj)
		end
	end

end