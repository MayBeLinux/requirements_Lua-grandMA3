local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local function OnSettingsChanged(settings, dummy, ctx)
    if (ctx) then
	    local isTimer = Enums.ClockSources[settings.ClockSource] == Enums.ClockSources.Timer;		
		local isTimecode = Enums.ClockSources[settings.ClockSource] == Enums.ClockSources.Timecode;
		local isSystemOrDate = not isTimecode and not isTimer;
		local titleButton = ctx.TitleBar.Title;

		if isSystemOrDate then
		    local isDate = (settings.SessionTimeStyle == "Date MM-DD-YYYY") or (settings.SessionTimeStyle == "Date DD-MM-YYYY");		
		    ctx.Frame.System.Visible = not isDate;
			ctx.Frame.Date.Visible = isDate;			
		else
		    ctx.Frame.System.Visible = false;
			ctx.Frame.Date.Visible = false;
		end

		ctx.Frame.Timecode.Visible = isTimecode;
		ctx.TitleBar.TitleButtons.Slot.Visible = isTimecode;
		ctx.TitleBar.TitleButtons.PlayButton.Visible = isTimecode;
		ctx.TitleBar.TitleButtons.StopButton.Visible = isTimecode;
		ctx.TitleBar.TitleButtons.PauseButton.Visible = isTimecode;

		ctx.Frame.Timer.Visible = isTimer;
		ctx.TitleBar.TitleButtons.TimerIndex.Visible = isTimer;
		ctx.TitleBar.TitleButtons.TimerPlayButton.Visible = isTimer;
		ctx.TitleBar.TitleButtons.TimerStopButton.Visible = isTimer;
		ctx.TitleBar.TitleButtons.TimerPauseButton.Visible = isTimer;

		local useSpecialTimezone = Enums.ClockSources[settings.ClockSource] == Enums.ClockSources["Time Zone"];
		ctx.Frame.System.UseSpecialTimezone = useSpecialTimezone;
		ctx.TitleBar.TitleButtons.TimezoneBtn.Visible = useSpecialTimezone;

		if useSpecialTimezone then
		    ctx.Frame.System.Visible = true;
			ctx.Frame.Date.Visible = false;
		end

		ctx.TitleBar.TitleButtons.SessionTimeStyleBtn.Visible = isSystemOrDate and not useSpecialTimezone;
		ctx.TitleBar.TitleButtons.SessionTimeStyleTZBtn.Visible = isSystemOrDate and useSpecialTimezone;

	end
end

signalTable.ClockWindowLoaded = function(caller,status,creator)
	local settings = caller.WindowSettings;
	HookObjectChange(OnSettingsChanged, settings, my_handle:Parent(), caller);
	OnSettingsChanged(settings, nil, caller);
	local titleBar = caller.TitleBar;
	local titleButtons = titleBar.TitleButtons
	local clockSource = titleButtons.ClockSource;
	local slot = titleButtons.Slot;
	local timer = titleButtons.TimerIndex;

	clockSource.Target = settings;
	slot.Target = settings;
	timer.Target = settings;
	titleButtons.TimezoneBtn.Target = settings;
	titleButtons.SessionTimeStyleBtn.Target = settings;
	titleButtons.SessionTimeStyleTZBtn.Target = settings;
end
