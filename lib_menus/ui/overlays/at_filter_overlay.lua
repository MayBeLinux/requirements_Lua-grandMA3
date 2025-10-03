local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.OnFilterLoaded = function(caller)
    local CurrentDisplay = caller:GetDisplay()
	local DisplayIndex = CurrentDisplay:Index()
	if (DisplayIndex ~= 1) then
		caller.Margin = "0,0,0,0"
	end
	signalTable.AtFilterSettings = CurrentProfile().TemporaryWindowSettings.AtFilterSettings;
end