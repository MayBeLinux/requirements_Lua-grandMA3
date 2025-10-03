local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.HelpViewerLoaded = function(caller,status,creator)
    local settings = caller.WindowSettings;
	caller.TitleBar.TitleButton.Settings = settings;
	caller.TitleBar.TitleButtons.ZoomFactor.Target = settings;
end
