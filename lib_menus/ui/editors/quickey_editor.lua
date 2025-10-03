local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.OnLoaded = function(caller,status,creator)	
end

signalTable.OnSetEditTarget = function(caller,dummy,target)
	if(#caller.EditTargetList > 0) then
		caller.Frame:SetChildren("Target",caller);
	else
		caller.Frame:SetChildren("Target",target);
	end
end