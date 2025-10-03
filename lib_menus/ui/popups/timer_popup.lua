-- Get the signal table, the plugin of this lua script --
local signalTable   = select(3,...); 

signalTable.UsePoolSelector = function()
	return true;
end

signalTable.GetPool = function(caller, dataPool)
	local timers;
	local profile = CurrentProfile();
	if (profile) then
		if (dataPool) then
			timers = dataPool.Timers;
		else
			local defaultDataPool = profile.SelectedDataPool;
			if(defaultDataPool) then
				timers = defaultDataPool.Timers;
			end
		end
	end

	return timers;
end

signalTable.GetEmptyText = function()
	return "<Link Selected>";
end

signalTable.CustomOnLoaded = function(list,status,creator)
	list.TitleBar.Title.Text = "Set Timer";
end

signalTable.GetRenderOptions = function()
	return {left_icon=true, number=false, right_icon=false};
end
