local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.BarLoaded = function(caller,status,creator)
	Echo("Executor bar loaded");
end

signalTable.OnSelectPage = function(caller)
	Cmd("menu WindowPagePool");
end
