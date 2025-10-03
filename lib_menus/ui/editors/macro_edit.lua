local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.OnSetEditTarget = function(caller,dummy,target)
	if not IsObjectValid(caller) then return; end
	caller.Content:SetChildren("TargetObject",target);
	caller.Content.ObjectSettings:SetChildren("Target",target);
	caller.FunctionButtons.FunctionRight:SetChildren("Target",target);
end

signalTable.OnCommand = function(caller,f)
	local editor = caller:FindParent("GenericEditor");
	local addr   = ToAddr(editor.EditTarget);
	if(addr) then 
	    local text=string.format("%s %s",f,addr);
		CmdIndirect(text); 
	end
end

signalTable.OnGo = function(caller)
	signalTable.OnCommand(caller,"Go");
end

signalTable.OnListReference = function(caller)
	signalTable.OnCommand(caller,"ListReference");
end