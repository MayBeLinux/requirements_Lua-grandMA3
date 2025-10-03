local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.GetPool = function(caller)
	local fixture = caller.Context;
	local stage = fixture.Stage;
	return stage.Spaces;
end

signalTable.CustomOnLoaded = function(caller,status,creator)
	caller.Frame.Popup.IndirectEdit = true;
end

signalTable.GetEmptyText = function()
	return nil;
end