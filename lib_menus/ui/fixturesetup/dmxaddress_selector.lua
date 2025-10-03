local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);



local function Main(display_handle)
end

signalTable.DoSelect = function(caller)
	local o = caller:GetOverlay();
	local g = o.UniverseGrid;
	o.OnAddressSelected('', g.SelectedColumn, g.SelectedRow);
end

return Main;
