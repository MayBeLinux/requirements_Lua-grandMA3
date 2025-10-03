local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.CreditDialogLoaded = function(caller,status,creator)
	if(caller.ReleaseNotesHelp ~= nil) then
	   local url  = "creditScreen";
	   caller.ReleaseNotesHelp.ReleaseNotesUrl = url;	
	end
end