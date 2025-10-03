local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.TitleButtonLoaded = function(caller, status, creator)
	caller.Text = "Group Pool Settings"
end