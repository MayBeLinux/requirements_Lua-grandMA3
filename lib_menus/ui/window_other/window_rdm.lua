local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

---------------------------------------------
signalTable.OnLoad = function(window,status,creator)
	local dbObjectGrid = window.Frame.Grid;
	
	dbObjectGrid.ExternalSettings       = window.WindowSettings;
	window.TitleBar.TitleButtons.ColumnConfig.Target = window.WindowSettings
end
