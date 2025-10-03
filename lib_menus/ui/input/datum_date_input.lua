local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.OnLoaded = function(caller,dummy,target)
	local datumInput = caller;
	local Frame=caller.Frame;
	Frame.Settings.Date:SetChildren("Target",datumInput);
end

signalTable.SetDateToday = function(caller)
	local o = caller:GetOverlay();
	o:SetDateToday();
end

signalTable.Apply = function(caller)
	local o = caller:GetOverlay();
	o.Close();
end

signalTable.Cancel = function(caller)
	local o = caller:GetOverlay();
	o.CloseCancel();
end