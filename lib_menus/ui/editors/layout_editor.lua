local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local TargetLayout;

signalTable.OnLoaded = function(caller,status,creator)	
    local ObjectGrid = caller.Frame.LayoutContent.ObjGrid;
    TargetLayout = caller.EditTarget;
    if ObjectGrid then
        ObjectGrid.TargetObject = caller.EditTarget;
    end
    caller.TitleBar.TitleButtons.ContentFilterEditor.Target = caller.Frame.LayoutContent.ObjGrid;
    caller.TitleBar.TitleButtons.LockBtn.Target = caller.EditTarget;
    HookObjectChange(signalTable.OnLayoutChanged,	caller.EditTarget,	my_handle:Parent(), caller);
    signalTable.OnLayoutChanged(caller.EditTarget, "", caller);
    signalTable.OnGenericEditLoaded(caller,status,creator);
end

signalTable.OnElementGridLoaded = function(grid,status,creator)	
    grid.SortByColumnName("Selected", Enums.GridSortOrder.Desc);
    grid:PreselectEntries();
end

signalTable.OnSetEditTarget = function(caller,dummy,target)
    caller.Frame.LayoutContent:SetChildren("TargetObject",target);
    caller.Frame.LayoutContent.ObjectSettings:SetChildren("Target",target);
end

signalTable.OnLayoutChanged = function(layout, signal, overlay)
    LockBtn = overlay.Frame.LayoutContent.lockBtn;
    if(layout.Lock == "Yes") then
        LockBtn.Visible = "Yes";
        LockBtn.ToolTip = "Layout " .. tostring(layout.index) .. " is locked";
        LockBtn.Text = "Please unlock Layout " .. tostring(layout.index) .. " to edit its elements.";
    else
        LockBtn.Visible = "No";
    end
end

signalTable.OnListReference = function(caller)
    local editor = caller:FindParent("GenericEditor");
    local addr   = ToAddr(editor.EditTarget);
    if(addr) then CmdIndirect("ListReference "..addr); end
end

signalTable.SetButtonsEnabled = function(maindlgbuttons, visibility)
    maindlgbuttons.Left.InsertBtn.Enabled = visibility;
    maindlgbuttons.Left.DeleteBtn.Enabled = visibility;
    maindlgbuttons.Left.CutBtn.Enabled    = visibility;
    maindlgbuttons.Left.CopyBtn.Enabled   = visibility;
    maindlgbuttons.Left.PasteBtn.Enabled  = visibility;
    maindlgbuttons.Right.EditBtn.Enabled  = visibility;
    maindlgbuttons.Right.LoadBtn.Visible	  = visibility;
    maindlgbuttons.Right.SaveBtn.Visible	  = visibility;
    if(visibility) then
        maindlgbuttons.Right.Spare.Anchors	  = ("3,1");
    else
        maindlgbuttons.Right.Spare.Anchors	  = ("1,1,3,1");
    end
end

signalTable.OnClickLayoutElementDefaults = function(caller)
    local Overlay = caller:FindParent("GenericEditor");

    -- set Layout Element Defaults Content
    local UP = CurrentProfile();
    local LEDCollect = UP.LayoutElementDefaultsCollect;
    Overlay.Frame.LayoutElementDefaults.TargetObject = LEDCollect;
    
    -- change Content
    Overlay.Frame.LayoutContent.Visible = false;
    Overlay.Frame.LayoutElementDefaults.Visible = true;

    Overlay.EditTarget = LEDCollect;

    -- set button state
    local SubMenu = caller:Parent();
    SubMenu.LayoutBtn.State = 0;
    SubMenu.LedBtn.State = 1;

    -- deactivate buttons (Insert, Delete, ...) for layout element DEFAULTS
    signalTable.SetButtonsEnabled(Overlay.MainDlgButtons, false)
end

signalTable.OnClickLayout = function(caller)
    local Overlay = caller:FindParent("GenericEditor");
    
    -- change Content
    Overlay.Frame.LayoutContent.Visible = true;
    Overlay.Frame.LayoutElementDefaults.Visible = false;

    Overlay.EditTarget = TargetLayout;

    -- set button state
    local SubMenu = caller:Parent();
    SubMenu.LayoutBtn.State = 1;
    SubMenu.LedBtn.State = 0;
    
    -- activate buttons (Insert, Delete, ...) for layout
    signalTable.SetButtonsEnabled(Overlay.MainDlgButtons, true)
end


-- **************************************************************************************************
-- load & save defaults functions 
-- **************************************************************************************************

signalTable.SaveAsDefault = function(caller)
    local Overlay = caller:GetOverlay();
    signalTable.FillSelectedElements(Overlay)
    signalTable.SaveDefaultsClicked(caller);
end

signalTable.LoadFromDefault = function(caller)
    local Overlay = caller:GetOverlay();
    signalTable.FillSelectedElements(Overlay)
    signalTable.LoadDefaultsClicked(caller);
end

signalTable.GetSelectedElement = function(Overlay)
    local ObjectGrid = Overlay.Frame.LayoutContent.ObjGrid;
    local grSel = ObjectGrid:GridGetSelection();
    local selectedItems = grSel.SelectedItems;
    if(#selectedItems>=1)then
        local object =  IntToHandle(selectedItems[1].row);
        if(object) then
            return object;
        end
    end

    return nil;
end


signalTable.FillSelectedElements = function(Overlay)	
    local ObjectGrid = Overlay.Frame.LayoutContent.ObjGrid;
    local grSel = ObjectGrid:GridGetSelection();
    local selectedItems = grSel.SelectedItems;


    local selObjects ={}
    for i=1,#selectedItems,1 do
        local obj = IntToHandle(selectedItems[i].row)
        if IsObjectValid(obj) then
            selObjects[#selObjects + 1] = obj
        end
    end
    Overlay.SelectedElements = selObjects
end

