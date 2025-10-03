local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.TrademarksDialogLoaded = function(caller,status,creator)
    if(caller.TrademarksHelp ~= nil) then
	    local url  = "key_grandma3_listoftrademarks.html";
	    caller.TrademarksHelp.TrademarksUrl = url;	
	end
end
