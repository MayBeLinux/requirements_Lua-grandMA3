local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);


signalTable.OnLoaded = function(caller,status,creator)
end


signalTable.OnSetEditTarget = function(caller,dummy,target)
	local Frame=caller.Frame;
	Global_CurrentSoundPoolElementNo	=target.No
	Frame:SetChildren("Target",target);
end



signalTable.ImportSound = function(caller,dummy,target)
	Cmd("menu SoundImport");
end
