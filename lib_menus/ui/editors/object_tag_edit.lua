local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);


signalTable.OnLoaded = function(caller,status,creator)
    signalTable.OnGenericEditLoaded(caller,status,creator);
end


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

signalTable.OnClickedInsert = function(caller)
	local assignEditor = Root().Menus.AssignmentEditor;
	if (assignEditor) then
		local assignEditorUI = assignEditor:CommandCall(caller,true--[[don't search focuse]],false--[[no buddies are allowed]]);
		if (assignEditorUI) then 
			assignEditorUI.Frame.Selector.ProvideEmpty = false;
			assignEditorUI:InputSetAdditionalParameter("SpecialCase", "Assign\nAssign\nButton");
			assignEditorUI:InputSetAdditionalParameter("DestinationClass", "Tag");
			assignEditorUI:InputSetAdditionalParameter("DestinationProperty", "DummyAssignable");
			assignEditorUI:InputSetAdditionalParameter("ForceReturnValue", "Yes");
			assignEditorUI:InputSetAdditionalParameter("Editable", "No");
			assignEditorUI:InputSetAdditionalParameter("Embedded", "No");

			assignEditorUI.W="80%";
			assignEditorUI.H="60%";

			local title = assignEditorUI.Title.TitleButton
			local tabs = assignEditorUI.Frame.Selector.AssignmentUITab
			local grid = assignEditorUI.Frame.Selector.GridArea.AssignmentGrid
			local button = assignEditorUI.Frame.Selector.GridArea.ButtonsArea.SpecialButtons.Assign

			title.Text = "Add Tag References"

			tabs:SelectListItemByIndex(1);
			assignEditorUI.Frame.Selector.ActiveSource = 0

			grid.SelectionType = "MultiRowGridSelection"
			grid.OnSelectedItem = ""
			grid.DoubleClicked = ""

			button.PluginComponent = my_handle
			button.Clicked = "ClickedAssignButton"
			button.W = 120

			assignEditorUI:Changed()
		end
	end
end

signalTable.ClickedAssignButton = function(caller)
	local grid = caller:FindParent("GenericAssignmentSelector").GridArea.AssignmentGrid

	local editor = caller:FindParent("GenericEditor")
	local tag = editor.EditTarget
	local editorGrid = editor.Content.ObjectTagGrid

	local selection = grid:GridGetSelectedCells()
	if not selection then
		selection = {}
	end

	local objects = {}
	for i=1,#selection do
		local row_id = selection[i].r_UniqueId
		local target = IntToHandle(row_id);
		if IsObjectValid(target) then
			if #objects > 0 then
				objects[#objects+1] = "+";
			end
			objects[#objects+1] = target:ToAddr();
		end
	end

	local concatTargets = table.concat(objects," ")
	CmdIndirectWait(string.format("Assign %s At %s ", tag, concatTargets))

	editorGrid:Changed()
end

signalTable.OnClickedDelete = function(caller)
	local editor = caller:FindParent("GenericEditor");
	local tag    = ToAddr(editor.EditTarget);

	local grid = editor.Content.ObjectTagGrid

	local selection = grid:GridGetSelectedCells()
	if not selection then
		selection = {}
	end

	local objects = {}
	for i=1,#selection do
		local row_id = selection[i].r_UniqueId
		local tagFake = IntToHandle(row_id);
		if IsObjectValid(tagFake) then
			local target = tagFake.ObjectHandle;
			if IsObjectValid(target) then
				if #objects > 0 then
					objects[#objects+1] = "+";
				end
				objects[#objects+1] = target:ToAddr();
			end
		end
	end

	local concatTargets = table.concat(objects," ")
	CmdIndirectWait(string.format("Assign Off %s At %s ", tag, concatTargets))

	grid:Changed()
end

signalTable.OnListReference = function(caller)
	signalTable.OnCommand(caller,"ListReference");
end