local signalTable   = select(3,...); 

signalTable.GetPool = function()
	return nil
end

signalTable.FilterSupport = function()
	return true
end

signalTable.FilterDefaultVisible = function()
	return true
end