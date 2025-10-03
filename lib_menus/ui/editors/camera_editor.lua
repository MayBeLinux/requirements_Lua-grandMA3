local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.OnLoaded = function(caller,status,creator)
	Echo("CameraEditor:OnLoaded");
end
signalTable.OnSetEditTarget = function(caller,dummy,target)
	Echo("CameraEditor:OnSetEditTarget");
	caller.Frame.PropertyButtons.target = target;
end


