local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.OnLoad = function(caller,status,creator)


end

signalTable.OnClickMe = function(caller,status)
	Echo("On click me!");
	caller:GetOverlay().Close("");
end

