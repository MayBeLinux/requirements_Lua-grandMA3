local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.OnResetToDefaults = function(caller, signal)
    local currentProfile = CurrentProfile();   	
	if (currentProfile) then
       local ksc = currentProfile.KeyboardShortCuts;
	   if (ksc) then
	       ksc.OnResetToDefault();	
	   end
	end
end
