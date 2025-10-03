local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

-- ***************************************************************************************************
-- VPU LUA Button Clicked
-- ***************************************************************************************************

signalTable.OnVPULuaButtonClicked = function(caller, value, buttonType, x, y)
	Echo("OnVPULuaButtonClicked:"..tostring(value));
	Echo("OnVPULuaButtonClicked param:"..tostring(buttonType).." X:"..tostring(x).." Y:"..tostring(y));
end
