local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.LocalSettingsLoaded = function(caller,status,creator)
	if (caller:WaitInit(1) ~= true) then
		ErrEcho("Failed to wait");
		return;
	end
end

