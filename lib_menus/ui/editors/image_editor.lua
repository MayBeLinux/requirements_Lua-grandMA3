local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);


signalTable.OnLoaded = function(caller,status,creator)
end


signalTable.OnSetEditTarget = function(caller,dummy,target)
	local Frame=caller.Frame; 
	local Left=Frame.Left;
	Global_CurrentImagePoolElementNo	=target.No
	Global_CurrentImagePoolName			=target:Parent().Name
	Left:SetChildren("Target",target);
	Frame.Preview.Appearance = target;
end



signalTable.ImportImage = function(caller,dummy,target)
	Cmd("menu ImageImport");
end
