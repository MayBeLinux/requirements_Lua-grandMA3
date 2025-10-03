-- Get the signal table, the plugin of this lua script --
local signalTable   = select(3,...); 
signalTable.OnAddNew = nil;

signalTable.GetEmptyText = function()
	return "All Stages";
end

signalTable.GetPool = function()
	return Patch().Stages;
end

