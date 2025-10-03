local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);


signalTable.OnLoaded = function(caller,status,creator)
end

signalTable.OnSetEditTarget = function(caller,dummy,target)
	local Left=caller.Frame.Left;
	local Center=caller.Frame.Center;
	local Right=caller.Frame.Right;
	Left:SetChildren("Target",caller.EditTarget);
	Center:SetChildren("Target",caller.EditTarget);
	Center.StartDatum:SetChildren("Target",caller.EditTarget);
	Right:SetChildren("Target",caller.EditTarget);
end

signalTable.Fire = function(caller)
	local window = caller:GetOverlay();
	window.EditTarget:Fire();
end