local signalTable   = select(3,...); 

signalTable.GetPool = function()
	return nil
end

signalTable.FilterSupport = function()
	return false
end

signalTable.FilterDefaultVisible = function()
	return false
end