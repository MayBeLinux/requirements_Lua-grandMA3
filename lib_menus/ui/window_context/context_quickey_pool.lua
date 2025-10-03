local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.QuickeyTarget = function(caller,status,creator)
	caller.Target=DataPool().Quickeys;
end

signalTable.TitleButtonLoaded = function(caller, status, creator)
	caller.Text = "Quickey Pool Settings"
end