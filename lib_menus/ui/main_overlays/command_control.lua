local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);




signalTable.OpenHelpPopup = function(caller)

    Cmd("Help _LAST_OPENED_HTML_");
	
end