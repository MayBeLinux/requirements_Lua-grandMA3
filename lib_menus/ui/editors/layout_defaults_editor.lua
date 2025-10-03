local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.OnLoaded = function(caller,status,creator)	
	local ObjectGrid = caller.Frame.ObjGrid;
	ObjectGrid.TargetObject = caller.EditTarget;
end

signalTable.OnSetEditTarget = function(caller,dummy,target)
	caller.Frame:SetChildren("Target",target);
end