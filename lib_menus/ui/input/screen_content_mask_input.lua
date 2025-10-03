local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.OnLoaded = function(caller,dummy,target)

 	local obj = caller.Context;
    signalTable.OnSetTarget(caller, nil, obj);

end


signalTable.OnSetTarget = function(caller,status,target)
	caller.Frame.Displays:SetChildren("Target",target);
end
