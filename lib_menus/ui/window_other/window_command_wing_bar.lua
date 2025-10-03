local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.SetSettingsTarget = function(caller)
	local window = caller:FindParent("CommandWingBarWindow");
	caller.target = window.WindowSettings
end


