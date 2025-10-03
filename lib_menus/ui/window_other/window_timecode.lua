local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local function OnSettingsChanged(settings, dummy, ctx)
	ctx.Frame.PlaybackToolbar.Visible = settings.ShowPlaybackToolbar;
	ctx:UpdateEncoderBar();
end

signalTable.TimecodeViewWindowLoaded = function(caller,status,creator)
	caller:WaitInit(3);
	local settings = caller.WindowSettings;
	HookObjectChange(OnSettingsChanged, settings, my_handle:Parent(), caller);
	OnSettingsChanged(settings, nil, caller);
end

signalTable.SetTarget = function(caller)
	local wnd = caller:FindParent("Window");
	caller.Target=wnd.WindowSettings;
end

signalTable.SetSharedTarget = function(caller)
	local wnd = caller:FindParent("Window");
	caller.Target=wnd.WindowSettings.TimecodeWindowSharedContainer.TimecodeWindowSharedData
end

signalTable.SetNavTarget = function(caller)
	local wnd = caller:FindParent("Window");
	caller.Target=wnd;
end



