local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);
local baseTitle

local function OnSettingsChanged(settings, dummy, ctx)
	local isHex = settings.Readout == Enums.DMXValueReadoutMode.Hex;
	local isDec = settings.Readout == Enums.DMXValueReadoutMode.Decimal;
	local isPercent = settings.Readout == Enums.DMXValueReadoutMode.Percent;

	local titleButton = ctx.TitleBar.Title;
	if (isHex) then
		titleButton.Text = (baseTitle .. " ReadoutMode: Hex" )
	else 
		if (isDec) then
			titleButton.Text = (baseTitle .. " ReadoutMode: Decimal" )
		else 
			if (isPercent) then
				titleButton.Text = (baseTitle .. " ReadoutMode: Percent" )
			end
		end
	end
end



signalTable.DMXSheetWindowLoaded = function(caller,status,creator)
	local settings = caller.WindowSettings;
	local dmxsheet = caller.Frame.DmxSheet
	baseTitle = caller.TitleBar.Title.Text
	if (settings) then
		local titleButtons = caller.TitleBar.TitleButtons;
		if (titleButtons) then
			titleButtons.ValueReadoutControl.Target = settings;
			titleButtons.OnlySelection.Target = settings;
			titleButtons.DmxTestBar.Target = settings;
			titleButtons.AddressMode.Target = settings;
			titleButtons.Levelbar.Target = settings;
			titleButtons.AutoColumns.Target = settings;
			titleButtons.AutoColumnsWidth.Target = settings;
			titleButtons.MaskValue.Target = settings;
			titleButtons.MaskAttribute.Target = settings;
			titleButtons.MaskID.Target = settings;
		else
			ErrEcho("[window dmx sheet]TitleButtons container was not found");
		end
		HookObjectChange(OnSettingsChanged, settings, my_handle:Parent(), caller);
		OnSettingsChanged(settings, nil, caller);
	else
		ErrEcho("[window dmx sheet]Settings object is null");
	end
end

signalTable.SetTargetSettings = function(caller,status,creator)
	local wnd = caller:FindParent("Window");
	local settings = wnd.WindowSettings;

	caller.Target = settings;
end
