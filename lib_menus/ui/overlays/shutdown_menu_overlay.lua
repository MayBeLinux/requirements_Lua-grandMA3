local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.ShutdownMenuDialogLoaded = function(caller,status,creator)
	if (HostType() == "onPC") then
	   caller.Content.Reboot.Visible = "No"
	   caller.Content.Columns = "3"
	   caller.Content.Restart.Anchors = "1,0"
	   caller.Content.Desklock.Anchors = "2,0"
	   caller.Content.PauseText.Anchors = "2,1"
	end
end
