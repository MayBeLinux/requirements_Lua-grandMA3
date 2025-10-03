local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.TimerTarget = function(caller,status,creator)
    local ContextEditor     = caller:GetOverlay();
    local ViewWidget        = ContextEditor.EditTarget;
	local WindowSettings    = ViewWidget:Ptr(1);
	caller.Target           = WindowSettings;	
end