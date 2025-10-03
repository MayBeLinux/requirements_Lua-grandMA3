local signalTable   = select(3,...); 

signalTable.GetPool = function()
	return DataPool().Filters;
end

signalTable.OnAddNew = nil;


