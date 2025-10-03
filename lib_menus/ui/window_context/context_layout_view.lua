local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.OnSetEditTarget = function(caller,dummy,viewwidget)
	local editor   = caller:GetOverlay();
	local settings = viewwidget.LayoutViewSettings;
	HookObjectChange(signalTable.OnSettingsChanged,settings,my_handle:Parent(),editor);
	signalTable.OnSettingsChanged(settings,nil,editor);
end

signalTable.OnSettingsChanged= function(settings, change, editor)
	local display = editor.Frame.Container.Display;

	local ButtonTable = {display.CanvasFitMode, display.AutoFit, display.FitType, display.ScaleFader};
	if (settings.Lock ~= "Yes") then		
		display.ScaleFader.Enabled=not settings.AutoFit;
	end
end