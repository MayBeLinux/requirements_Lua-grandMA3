local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.OnLoaded = function(caller,status,creator)   
end

signalTable.OnSetEditTarget = function(caller,dummy,target)
	caller.Frame:SetChildren("Target",target);	
end

signalTable.LoadFromDefault = function(caller)
 local window = caller:GetOverlay();
 window.EditTarget.LoadFromDefault(CmdObj());
end

signalTable.SaveToDefault = function(caller)
 local window = caller:GetOverlay();
 window.EditTarget.SaveToDefault(CmdObj());
end


