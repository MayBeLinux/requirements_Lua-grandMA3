local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);


signalTable.OnLoaded = function(caller,status,creator)
end

signalTable.OnSetEditTarget = function(caller,dummy,target)
	caller.Frame:SetChildren("Target",target);
end

signalTable.OnListReference = function(caller)
	local editor = caller:FindParent("GenericEditorOverlay");
	local addr   = ToAddr(editor.EditTarget);
	if(addr) then CmdIndirect("ListReference "..addr); end
end

signalTable.OnRecast = function(caller)
	local editor = caller:FindParent("GenericEditorOverlay");
	local addr   = ToAddr(editor.EditTarget);
	if(addr) then CmdIndirect("Recast "..addr); end
end




