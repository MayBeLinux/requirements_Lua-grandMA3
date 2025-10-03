local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.LoadButtonLoaded = function(caller,status,creator)
    caller.SignalValue = "PluginPool"	
end

signalTable.SaveButtonLoaded = function(caller, status, creator)
    caller.SignalValue = "PluginPool"
end

signalTable.TitleButtonLoaded = function(caller, status, creator)
    caller.text = "Plugin Pool Settings"
end

signalTable.PluginActionTarget = function(caller,status,creator)
    local ContextEditor     = caller:GetOverlay();
    local ViewWidget        = ContextEditor.EditTarget;
	local WindowSettings    = ViewWidget:Ptr(1);
	caller.Target           = WindowSettings;	
end