local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);


signalTable.SetTargetGrid = function(caller)
	local o = caller:GetOverlay();
	caller.Target=o.Content.Timecode;
end

signalTable.SetTarget = function(caller)
	local o = caller:GetOverlay();
	caller.Target=o.Content.Timecode:GridGetSettings();
end

signalTable.SetSharedTarget = function(caller)
	local o = caller:GetOverlay();
	caller.Target=o.Content.Timecode:GridGetSettings().TimecodeWindowSharedContainer.TimecodeWindowSharedData;
end

signalTable.SetNavTarget = function(caller)
	caller.Target = caller:GetOverlay();
end

