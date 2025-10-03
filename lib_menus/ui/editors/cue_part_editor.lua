local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);


signalTable.OnLoaded = function(caller,status,creator)
end

signalTable.OnSetEditTarget = function(caller,dummy,target)
	local Frame=caller.Frame;
	Frame:SetChildren("Target",target);
	Frame.RecipeGrid.TargetObject=target;
end

signalTable.OnCook = function(caller)
	local editor = caller:FindParent("GenericEditorOverlay");
	local part = editor.EditTarget;
	local cue  = part:Parent();
	local sequ = cue:Parent();
	local s = string.format("Cook Sequ '%s' Cue '%s' Part '%s'",sequ.Name,cue.Name,part.Name);
	CmdIndirect(s);
end
