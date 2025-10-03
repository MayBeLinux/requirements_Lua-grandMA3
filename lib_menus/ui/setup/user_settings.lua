local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.OnSettingsLoaded = function(caller)
	signalTable.UpdateButtonsTarget(caller)
	HookObjectChange(signalTable.UpdateButtonsTarget,  -- 1. function to call
					 caller,							-- 2. object to hook
					 my_handle:Parent(),				-- 3. plugin object ( internally needed )
					 caller);							-- 4. user callback parameter 	
end

signalTable.UpdateButtonsTarget = function(caller)
	caller.PropertyButtons.target = caller.target;
	caller.Preview.Appearance = caller.target;
end
