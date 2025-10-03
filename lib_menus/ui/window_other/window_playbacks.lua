local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local settings;

signalTable.PlaybackViewLoaded = function(caller,status,creator)
	settings = caller.WindowSettings;
	caller.Title.TitleButtons:SetChildren("Target",settings)
end

signalTable.SetTarget = function(caller)
	caller.Target=settings;
end

