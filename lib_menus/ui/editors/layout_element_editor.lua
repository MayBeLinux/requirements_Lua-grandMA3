local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.OnLoaded = function(caller,status,creator)	
	local layout = caller.EditTarget:Parent();
	HookObjectChange(signalTable.OnLayoutChanged, layout, my_handle:Parent(), caller);
	signalTable.OnLayoutChanged(layout, "", caller);
end

signalTable.OnSetEditTarget = function(caller,dummy,target)
	if(#caller.EditTargetList > 0) then
		caller.Frame.Container.General:SetChildren("Target",caller);
		caller.Frame.Container.Arrangement:SetChildren("Target",caller);
		caller.Frame.Container.CustomText:SetChildren("Target",caller);
	else
		caller.Frame.Container.General:SetChildren("Target",target);
		caller.Frame.Container.Arrangement:SetChildren("Target",target);
		caller.Frame.Container.CustomText:SetChildren("Target",target);
	end
end


signalTable.OnLayoutChanged = function(layout, signal, overlay)
	LockBtn = overlay.Frame.lockBtn;
	if(layout.Lock == "Yes") then
		LockBtn.Visible = "Yes";
		LockBtn.ToolTip = "Layout " .. tostring(layout.index) .. " is locked";
		LockBtn.Text = "Please unlock Layout " .. tostring(layout.index) .. " to edit its elements.";
	else
		LockBtn.Visible = "No";
	end
	signalTable.CheckForFixture(overlay.Frame.Container.General);
end

signalTable.OnListReference = function(caller)
	local editor = caller:FindParent("GenericEditorOverlay");
	local addr   = ToAddr(editor.EditTarget);
	if(addr) then CmdIndirect("ListReference "..addr); end
end

signalTable.CheckForFixture = function(caller)
	local Overlay = caller:GetOverlay();
	if(Overlay.EditTarget.AssignType == "Fixture") then
		caller.CID.Visible = true;
	else
	 	caller.CID.Visible = false;
	end
end

-- **************************************************************************************************
-- load & save defaults functions 
-- **************************************************************************************************

signalTable.SaveAsDefault = function(caller)
	signalTable.SaveDefaultsClicked(caller);
end

signalTable.LoadFromDefault = function(caller)
	signalTable.LoadDefaultsClicked(caller);
end

signalTable.GetSelectedElement = function(Overlay)
	return Overlay.EditTarget;
end
