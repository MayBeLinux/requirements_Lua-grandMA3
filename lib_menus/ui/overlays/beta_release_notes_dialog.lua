local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.BetaReleaseNotesDialogLoaded = function(caller,status,creator)
    if(caller.ReleaseNotesHelp ~= nil) then
	   local url  = "splash_key_releasenotes_beta.html";
	   caller.ReleaseNotesHelp.ReleaseNotesUrl = url;	
	end
end
