local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local function GetFilterContentObject(o)
    return o.Frame.Selector.GridArea.AssignmentGrid:GridGetSettings():Ptr(3);
end

local function GetFilterItem(o)
    return GetFilterContentObject(o).Filter;
end

signalTable.OnLoad = function(caller,status,creator)
	local SelectorObj = caller.frame.Selector

	local addArgs = caller.AdditionalArgs;
	local embedded = false;
	local editable = nil;
	if ((addArgs ~= nil) and (addArgs.Embedded ~= nil)) then embedded = addArgs.Embedded == "Yes"; end;
	if ((addArgs ~= nil) and (addArgs.Editable ~= nil)) then editable = addArgs.Editable == "Yes"; end;

	if (embedded) then
		-- caller.W = "800"
		-- caller.H = "480"
		-- caller.MinSize = ""
		caller.RelativeToDisplay = false;
		caller.Title.Visible=false;
		caller.Resizer.Visible=false;
		caller.Frame.Selector.GridArea.AssignmentGrid.OnSelectedItem = "";
		caller.Frame.Selector.GridArea.ButtonsArea.Select.Visible = true;
		caller.Frame.Texture = Root().GraphicsRoot.TextureCollect.Textures["frame15"]; 
		caller.Frame.Selector.GridArea.AssignmentGrid.Focus = Enums.FocusPriority.CanHaveFocus;
		caller.Frame.Selector.GridArea.ButtonsArea.Select.Focus = Enums.FocusPriority.WantsFocus;
	else
		caller.Frame.Selector.GridArea.AssignmentGrid.DoubleClicked = "";
	end

	caller:WaitInit(1);
	if (editable == true) then
		caller.Frame.Selector.GridArea.AssignmentGrid.AllowEdit = true;
		caller.Frame.Selector.GridArea.AssignmentGrid.AllowAddContent = true;
		caller.Frame.Selector.GridArea.AssignmentGrid.AllowAddNewLine = true;
		caller.Frame.Selector.GridArea.AssignmentGrid.EditAllowedAdd = true;
	end

	local filter = caller.FilterComposed;
	local filterItem = GetFilterItem(caller);
    filterItem.Columns = filter;
end

signalTable.SelectClicked = function(caller)
	local o = caller:GetOverlay();
	local sel = o.Frame.Selector;
	local gr = sel.GridArea.AssignmentGrid;
	sel.OnDBObjectSelected("", 1, gr.SelectedRow);
end

-- --------------- Filter --------------------------------
signalTable.SetFilterTarget = function(caller, newFilter)
	local o = caller:GetOverlay();
	caller:WaitInit(1);
    caller.Target = GetFilterItem(o);
	caller:WaitInit(1);
	caller.SelectAll();
	o.Title.AttributeFilterButton.Target = o:FindRecursive("AttributeFilter", "GridContentFilterItem");
end

signalTable.AssignFilterChanged = function(caller, newFilter)
	GetFilterItem(caller).Columns = newFilter;
end

signalTable.TextToFilter = function(caller)
	caller:GetOverlay().FilterComposed = ""
end

signalTable.ClearSearch = function(caller,dummy)
	caller:Parent().SearchEdit.Clear();
end

signalTable.SelectFirstEntry = function(caller)
	local o = caller:GetOverlay();
	local sel = o.Frame.Selector;
	local gr = sel.GridArea.AssignmentGrid;
	local c = gr:GridGetCellData({r=2, c=1})
	sel.OnDBObjectSelected("", 1, c.row_id);
end
