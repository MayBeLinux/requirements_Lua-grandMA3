local signalTable   = select(3,...); 

signalTable.GetPool = function()
	return DataPool().Matricks;
end

signalTable.FilterSupport = function()
	return true
end

signalTable.FilterDefaultVisible = function()
	return true
end




