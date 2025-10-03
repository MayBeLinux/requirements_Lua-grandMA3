local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.LoadButtonLoaded = function(caller,status,creator)
    caller.SignalValue = "GeneratorPool"	
end

signalTable.SaveButtonLoaded = function(caller, status, creator)
    caller.SignalValue = "GeneratorPool"
end

signalTable.TitleButtonLoaded = function(caller, status, creator)
    caller.text = "Generator Pool Settings"
end