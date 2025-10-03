local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local pVars = nil;

local function UpdateColumnFilter(content)
    local filter = GetVar(pVars, "ColumnFilter");
    content.MainDlg.OopsGrid:WaitInit(2);
    local s = content.MainDlg.OopsGrid:GridGetSettings();
    local filterCollect = s:Ptr(1);
    filterCollect.SelectedFilter = filter;
end

local function GetParent(caller)
    local parentOverlay = caller:Parent():FindParent("MainDialog");
    if (parentOverlay == nil) then
        local parentWindow = caller:Parent():FindParent("Window");
        if (parentWindow ~= nil) then
            return parentWindow;
        else
            return nil;
        end
    else
        return parentOverlay;
    end
end

signalTable.OnLoad = function(caller)
    caller:WaitInit(1);
    pVars = PluginVars():Ptr(1);
    caller.MainDlg.OopsGrid.TargetObject = CmdObj().Undos
    caller.MainDialogFunctionButtons.FunctionLeft.CreateOopsButton.Target = CurrentProfile()
    caller.MainDialogFunctionButtons.FunctionLeft.ViewsOopsButton.Target = CurrentProfile()
    caller.MainDialogFunctionButtons.FunctionLeft.ProgrammerOopsButton.Target = CurrentProfile()
    caller.MainDialogFunctionButtons.FunctionLeft.SelectionOopsButton.Target = CurrentProfile()
    caller.MainDialogFunctionButtons.FunctionRight.OopsConfirmationButton.Target = CurrentProfile()
    caller.MainDlg.OopsGrid:SelectRow(HandleToInt(CmdObj().Undos:Ptr(CmdObj().Undos.UndoIndex + 1)))
    HookObjectChange(signalTable.UndosChanged, CmdObj().Undos, my_handle:Parent(), caller);
    signalTable.OnSelectedRowChanged(caller.MainDlg.OopsGrid)

    local parent = GetParent(caller);
    local colFiltersBtn = parent.TitleBar.ColumnsFilters;
    colFiltersBtn:ClearList();
    colFiltersBtn:AddListStringItem("Elapsed Time", "ElapsedTime");
    colFiltersBtn:AddListStringItem("Session Time", "SessionTime");
    local selectedFilter = GetVar(pVars, "ColumnFilter");
    if (selectedFilter ~= nil) then
        colFiltersBtn:SelectListItemByValue(selectedFilter);
    else
        colFiltersBtn:SelectListItemByValue("ElapsedTime");
        SetVar(pVars, "ColumnFilter", "ElapsedTime");
    end
    UpdateColumnFilter(caller);
    local grid = caller.MainDlg.OopsGrid;
    selCells = grid:GridGetSelectedCells();
    if (selCells) then
        grid:GridScrollCellIntoView(selCells[#selCells]);
    end
    local o = caller:GetOverlay();
    if(o) then
        o.TitleBar.ColumnsFilters.PluginComponent = my_handle
    else
        local window = caller:FindParent("Window");
        window.TitleBar.ColumnsFilters.PluginComponent = my_handle
    end
end

signalTable.OnSelectedRowChanged = function(caller,status,creator)
    local selection = caller:GridGetSelection();
    local items = selection.SelectedItems;
    local Button = caller:Parent():Parent().MainDialogFunctionButtons.FunctionRight.UndoButton
    if (#items > 1) then
        Button.Text = "Oops " .. #items .. " Actions"
    else
        Button.Text = "Oops Last Action"
    end
end

signalTable.UndoButtonClicked = function(caller,signal)
    local selection = caller:Parent():Parent():Parent().MainDlg.OopsGrid:GridGetSelection();
    local items = selection.SelectedItems;
    CmdIndirect("Undo " .. #items .. " /NoConfirm")
end

signalTable.UndosChanged = function(signal, dummy, caller)
    local grid = caller.MainDlg.OopsGrid;
    selCells = grid:GridGetSelectedCells();
    if selCells then
        grid:GridScrollCellIntoView(selCells[#selCells]);
    end
    signalTable.OnSelectedRowChanged(grid)
end

signalTable.ColumnsFilterSelected = function(caller, dummy, handleInt, idx)
    local filter = caller:GetListItemValueStr(idx + 1);
    local o = caller:GetOverlay();
    SetVar(pVars, "ColumnFilter", filter);

    if(o) then
        UpdateColumnFilter(o.Frame.OopsPlaceHolder.OopsContent);
    else
        local window = caller:FindParent("Window");
        UpdateColumnFilter(window.Frame.OopsPlaceHolder.OopsContent);
    end
    
end