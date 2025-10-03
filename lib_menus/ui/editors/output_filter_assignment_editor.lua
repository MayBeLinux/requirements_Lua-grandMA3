local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

signalTable.OnLoad = function(caller,status,creator)
	local SelectorObj = caller.frame.Selector

	caller:WaitInit(1);
	if (editable == true) then
		SelectorObj.GridArea.AssignmentGrid.AllowEdit = true;
		SelectorObj.GridArea.AssignmentGrid.AllowAddContent = true;
		SelectorObj.GridArea.AssignmentGrid.AllowAddNewLine = true;
		SelectorObj.GridArea.AssignmentGrid.EditAllowedAdd = true;
	end

	caller.Title.ContentFilterEditor.Target = SelectorObj.GridArea.AssignmentGrid.Internals.GridBase.GridSettings.GridObjectContentFilter.HasDynamicRule;
end

signalTable.SelectFirstEntry = function(caller)
	local o = caller:GetOverlay();
	local sel = o.Frame.Selector;
	local gr = sel.GridArea.AssignmentGrid;
	local c = gr:GridGetCellData({r=2, c=1})
	sel.OnDBObjectSelected("", 1, c.row_id);
end

signalTable.PageChanged = function(caller)	
	local o = caller:GetOverlay();
	local selector = o.Frame.Selector;
	selector.GridArea.AssignmentGrid.Internals.GridBase.GridSettings.GridObjectContentFilter.HasDynamicRule.Enabled = (selector.ActiveSource ~= 2);	
end
