local signalTable   = select(3,...); 

signalTable.UsePoolSelector = function()
	return true;
end

signalTable.GetPool = function(caller, dataPool)
	return dataPool.Groups
end

signalTable.GetRenderOptions = function()
	return {left_icon=true, number=false, right_icon=false};
end

signalTable.FilterSupport = function()
	return true
end

signalTable.FilterDefaultVisible = function()
	return true
end




