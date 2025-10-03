local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);
-- ------------------------------------------
signalTable.OnLoad = function(window,status,creator)
	local SettingsObj = window.WindowSettings
	HookObjectChange(signalTable.SettingsChanged,		-- 1. function to call
					 SettingsObj,						-- 2. object to hook
					 my_handle:Parent(),				-- 3. plugin object ( internally needed )
					 window);							-- 4. user callback parameter 
end
-- ------------------------------------------
signalTable.SettingsChanged = function(Settings,Plugin,window)
	if Settings.ShowBottomMenu then	
		window.Menu.Visible = "Yes"
	else	
		window.Menu.Visible = "No"
	end
	window:Changed(); -- THIS IS NECESSARY to reconnect signals
end

-- ------------------------------------------
signalTable.InitMenu = function(Menu)
	local SettingsObj = Menu:Parent().WindowSettings
	if SettingsObj.ShowBottomMenu then	
		Menu.Visible = "Yes"
	else	
		Menu.Visible = "No"
	end
	Menu:Changed() -- THIS IS NECESSARY to reconnect signals
end
