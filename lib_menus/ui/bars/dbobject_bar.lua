local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.BarLoaded = function(bar,status,window)
	bar.InnerBox.Pages.Target = bar
end
