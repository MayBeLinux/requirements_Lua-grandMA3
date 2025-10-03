local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);



signalTable.UsePoolSelector = function()
	return true;
end

signalTable.GetPool = function(caller, dataPool)
	local timecodes;
	local profile = CurrentProfile();
	if (profile) then
		if (dataPool) then
			timecodes = dataPool.Timecodes;
		else
			local defaultDataPool = profile.SelectedDataPool;
			if(defaultDataPool) then
				timecodes = defaultDataPool.Timecodes;
			end
		end
	end

	return timecodes;
end

signalTable.GetEmptyText = function()
	return "<Link Selected>";
end

signalTable.GetRenderOptions = function()
	return {left_icon=true, number=false, right_icon=false};
end