local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.OnLoaded = function(caller,status,creator)
    if(caller.IsMainBuddy) then
	   signalTable.BaseInput=caller;
	end
end

signalTable.OnOverwriteClicked = function(caller,status,creator)
	local text=signalTable.BaseInput.StrContext .. " /OVERWRITE";
	CmdIndirect(text,signalTable.BaseInput);
	signalTable.BaseInput.Close();
end

signalTable.OnMergeClicked = function(caller,status,creator)
	local text=signalTable.BaseInput.StrContext .. " /MERGE";
	CmdIndirect(text,signalTable.BaseInput);
	signalTable.BaseInput.Close();
end

signalTable.OnCancelClicked = function(caller,status,creator)
	signalTable.BaseInput.Close();
end
