local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.TitleButtonLoaded = function(caller, status, creator)
	caller.Text = "Timecode Slots Pool Settings"
end

signalTable.LoadButtonLoaded = function(caller,status,creator)
    caller.SignalValue = "TimecodeSlotPool"	
end

signalTable.SaveButtonLoaded = function(caller, status, creator)
    caller.SignalValue = "TimecodeSlotPool"
end

signalTable.TimecodeSlotActionTarget = function(caller,status,creator)
    local ContextEditor     = caller:GetOverlay();
    local ViewWidget        = ContextEditor.EditTarget;
	local WindowSettings    = ViewWidget:Ptr(1);
	caller.Target           = WindowSettings;	
end
