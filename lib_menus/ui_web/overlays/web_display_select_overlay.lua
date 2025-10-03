local pluginName    = select(1,...);
local componentName = select(2,...);
local signalTable   = select(3,...);
local my_handle     = select(4,...);

signalTable.SetTargetOnLoad = function(caller)
	caller.Target = caller:GetDisplay().WSRemoteConnection;
end
