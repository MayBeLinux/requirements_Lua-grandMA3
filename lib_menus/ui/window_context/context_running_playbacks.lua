local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.OnContextLoaded = function(caller)
	HookObjectChange(signalTable.OnSettingsChanged, caller.WindowSettings, my_handle:Parent(), caller);
	signalTable.OnSettingsChanged(caller.WindowSettings, my_handle:Parent(), caller)
end

signalTable.OnSettingsChanged = function(settings, _, overlay)
	overlay.Frame.Container.Display.ContextUserControl.Enabled = not settings.MyPlaybacksOnly
end