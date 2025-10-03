local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.LoadButtonLoaded = function(caller,status,creator)
    caller.SignalValue = "LayoutPool"	
end

signalTable.SaveButtonLoaded = function(caller, status, creator)
    caller.SignalValue = "LayoutPool"
end

signalTable.TitleButtonLoaded = function(caller, status, creator)
    caller.text = "Layout Pool Settings"
end