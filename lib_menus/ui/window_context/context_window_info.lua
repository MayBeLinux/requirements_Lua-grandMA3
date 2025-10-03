local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);


signalTable.OnLoadInfoSettings = function(window,status,creator)
    local settings = window.WindowSettings;
    local currentLinkMode = Enums.InfoLinkMode[settings.LinkMode];
    --caller.TitleBar.Buttons.RefMode.enabled = (currentLinkMode == Enums.InfoLinkMode.None);

    HookObjectChange(signalTable.ContextSettingsChanged,settings, my_handle:Parent(), window);
	signalTable.ContextSettingsChanged(settings, nil, window)
end

signalTable.ContextSettingsChanged = function(settings, dummy, window)
    signalTable.initWindowModeBtn(window.DialogFrame.DialogContainer.Display.WindowMode, settings);
    signalTable.initLinkModeBtn(window.DialogFrame.DialogContainer.Display.LinkMode, settings);
end