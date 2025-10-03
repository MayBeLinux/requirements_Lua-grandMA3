local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);

local function GetPsrShowfile()
    return Root().Temp.ConvertTask.ShowfileName
end

local function UpdatePsrShowfile(overlay)
    local fileName = overlay.Frame.ShowFilesViewContainer.ShowFilesView.SelectedFile;
    
    if(fileName ~= "") then
        Root().Temp.ConvertTask.ShowfileName = fileName
    end
end

local function StartPsrPreparation()
    Root().Temp.ConvertTask:OnRunPreparation();
end

-----------------------------------------------------------
-- Drive Change Handling

signalTable.OnDriveChanged = function(overlay)
    -- Update FileGrid path:
    local path = signalTable.GetCurrentPath(Enums.PathType.Showfiles)
    overlay.Frame.ShowFilesViewContainer.ShowFilesView.SetPath(path);

    -- Update FileGrid Metadata and Selection:
end

-----------------------------------------------------------
-- GOTO FUNCTIONS

local function ChangeModeTo(overlay, newMode)
    overlay.Mode = newMode
    -- Adjustments to mode:
    signalTable.SetFilterContent(overlay, "")
    signalTable.UpdateDescription(overlay, overlay.Mode ~= Enums.ShowfileSelectorMode.Saveas)
    -- Visiblity:
    overlay.Frame.Visible = true

    overlay.Title.Filter.visible = false
    overlay.Frame.HeadContainer.SearchBar.visible = true
    overlay.Frame.HeadContainer.Clear.visible     = true
    overlay.Frame.HeadContainer.BackBtn.visible   = false
    overlay.Frame.HeadContainer.DriveStatus.visible   = false

    overlay.Frame.LoadOptionsContainer.Visible = false

    overlay.Frame.ButtonArea.History.Visible = 1
    overlay.Frame.ButtonArea.Description.Visible = 1
    overlay.Frame.ButtonArea.SelectShowBtn.Visible = 1

    overlay.Frame.ShowFilesViewContainer.ShowFilesView.Visible = 1

    FindBestFocus(overlay.Frame.HeadContainer.SearchBar);
  
    overlay.Frame.ShowFilesViewContainer.ShowFilesView.SelectionType="SingleRowGridSelection"
end

-----------------------------------------------------------
-- OnLoad

signalTable.PsrShowLoaded = function(caller,status,creator)
   
    signalTable.ShowSelectorLoaded(caller)
    
    caller.Frame.History.Visible = false
    caller.Frame.ButtonArea.History.Target = caller.Frame.History
    caller.Frame.ButtonArea.Description.Target = caller.Frame.Description
    
    caller.Title.DriveSelector:SelectListItemByIndex(1);
    signalTable.OnDriveChanged(caller);
    HookObjectChange(signalTable.DriveCollectChanged, Root().Temp.DriveCollect, my_handle:Parent(), caller);
    HookObjectChange(signalTable.GridSelectionChanged, caller.Frame.ShowFilesViewContainer.ShowFilesView:GridGetSelection(), my_handle:Parent(), caller);
    HookObjectChange(signalTable.ManetSocketChanged, Root().ManetSocket, my_handle:Parent(), caller);
    
    caller.Frame.ShowFilesViewContainer.ShowFilesView.SelectedFile = GetPsrShowfile()
    
    ChangeModeTo(caller, Enums.ShowfileSelectorMode.Startupshow)
    signalTable.UpdateDescription(caller, caller.Mode ~= Enums.ShowfileSelectorMode.Saveas)
    signalTable.ManetSocketChanged(nil, nil, caller);
end

signalTable.ManetSocketChanged = function(ManetSocket,status,creator)
    if( Root().Temp.ConvertTask.PSRAllowed ) then
        creator.Frame.Enabled = "Yes";
        creator.NetworkEnabledMsg.Visible = "No";
    else
        creator.Frame.Enabled = "No";
        creator.NetworkEnabledMsg.Visible = "Yes";
    end
end

----------------------------------------------------------
-- SelectShowBtnClicked

signalTable.SelectShowBtnClicked = function(caller)
    local overlay = caller:GetOverlay();
    local parentDialog = overlay:Parent():Parent();
    parentDialog.PsrMenu.SubTabs:SelectListItemByIndex(2)
    UpdatePsrShowfile(overlay)
    StartPsrPreparation()
end 

-----------------------------------------------------------
-- Selection changed

signalTable.OnFileSelected = function(caller,dummy,rowid)
    local overlay = caller:GetOverlay()
    signalTable.SelectWholeText(overlay.Frame.HeadContainer.NameInput)
    if (Root().ShowData.ShowSettings.ShowMetaData.ShowShowHistory) then
        overlay.Frame.History.ShowHistoryGrid.CurrentSelectedShowFile = caller.SelectedFile;
        overlay.Frame.History.ShowHistoryGrid.ReTriggerInit();
    end

    UpdatePsrShowfile(overlay)
end

signalTable.GridSelectionChanged = function(caller,_,overlay)
    signalTable.UpdateDescription(overlay, overlay.Mode ~= Enums.ShowfileSelectorMode.Saveas)
end

-----------------------------------------------------------
-- Filter Textinput Actions

signalTable.OnFilterChanged = function(caller, signal)
    local overlay = caller:GetOverlay()

    if(overlay.Frame.ShowFilesViewContainer.ShowFilesView.hasFocus == false) then
        overlay.Frame.ShowFilesViewContainer.ShowFilesView.FuzzyFilter = signalTable.GetFilterContent(overlay)
    end
end