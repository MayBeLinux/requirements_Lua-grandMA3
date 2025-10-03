local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);



signalTable.OnLoaded = function(caller,status,creator)
	local obj = caller.Context;
	local propName = caller.StrContext;

	local idx = obj[propName];
	local btnName = "D"..tostring(idx);
	local btn = caller.Frame.Displays[btnName];
	if (btn) then
		btn.Focus = "InitialFocus";
		btn.State = true;
	end
end

signalTable.OnSetTarget = function(caller,status,creator)
	local o = caller:GetOverlay();
	o.Value = caller.SignalValue;
	o.Close();
end

signalTable.OnClear = function(caller,status,creator)
	local o = caller:GetOverlay();
	o.Value = "None";
	o.Close();
end

