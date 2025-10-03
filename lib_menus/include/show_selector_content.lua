local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);


-----------------------------------------------------------
-- OnLoad

signalTable.ShowSelectorLoaded = function(caller)
    caller:WaitInit(1)

    caller.Frame.ShowFilesViewContainer.ShowFilesView.SortByColumn("Desc", 0);
    caller.Frame.LoadOptionsContainer.ShowData.Target = caller;
    caller.Frame.LoadOptionsContainer.LocalSettings.Target = caller;
    caller.Frame.LoadOptionsContainer.OutputStations.Target = caller;
    caller.Frame.LoadOptionsContainer.DmxProtocols.Target = caller;

    -- limit the splitted additional content, to avoid area overflow
    local otherRequestedHeight = 280
    caller.Frame.History.MaxSize="0,"..caller.AbsRect.h - otherRequestedHeight
    caller.Frame.Description.MaxSize="0,"..caller.AbsRect.h - otherRequestedHeight
    caller.Frame:Changed()

    HookObjectChange(signalTable.LocalSettingsChanged, Root().StationSettings.LocalSettings, my_handle:Parent(), caller);
end

-----------------------------------------------------------
-- Filter

signalTable.ClearFilters = function(caller, signal)
    local inputLine = caller:Parent().SearchBar;
    inputLine.Clear();
    signalTable.OnFilterChanged(inputLine, signal);
end

signalTable.ClearFileName = function(caller, signal)
    local inputLine = caller:Parent().NameInput;
    inputLine.Clear();
end

signalTable.SelectWholeText = function(caller)
    caller.SelectAll();
end

function signalTable.SetFilterContent(overlay, t)
    overlay.Frame.HeadContainer.SearchBar.Content = t
end

function signalTable.GetFilterContent(overlay)
    local fileNameEdit = overlay.Frame.HeadContainer.SearchBar;
    return fileNameEdit.Content;
end

signalTable.SetFocusToFilter = function(caller, dummy, character)
    local overlay = caller:GetOverlay()
    if(caller.HasFocus == true) then
        overlay.Frame.HeadContainer.SearchBar.Content = utf8.char(character);
        overlay.Frame.HeadContainer.SearchBar:SetCursorToEnd();
        FindBestFocus(overlay.Frame.HeadContainer.SearchBar);
    end
end

function signalTable.GetSaveShowName(overlay)
    return overlay.Frame.HeadContainer.NameInput.Content
end


function signalTable.CutShowEnding(name)
    return name:gsub("%.show$", "");
end

function signalTable.RebuildShowfileEnding(name)
    -- allows filtering with parts of show ending, e.g. "someshow.sho"
    local name = signalTable.CutShowEnding(name)
    return name..".show"
end

function signalTable.GridHasMultiSelection(overlay)
    local selectedItems = overlay.Frame.ShowFilesViewContainer.ShowFilesView:GridGetSelection().SelectedItems;
    local hasMultiSelection = (selectedItems ~= nil) and (#selectedItems > 1) or false;
    return hasMultiSelection;
end

-----------------------------------------------------------
-- signalTable.GetCurrentPath

function signalTable.GetCurrentPath(pathTypeEnum)
    local drive = SelectedDrive()
    local path;
    if (drive:Index() == 1) then
        path = "";
    else
        path = drive.Path;
    end
    return GetPathOverrideFor(pathTypeEnum, path);
end

-----------------------------------------------------------
-- Drive Changed (Internal, USB, ..)

signalTable.DriveCollectChanged = function(obj, change, caller)
    Cmd("Select Drive 1")
end

signalTable.LocalSettingsChanged = function(obj, change, caller)
    if IsObjectValid(caller) then
        local overlay = caller:GetOverlay()
        -- drive possibly changed:
        signalTable.OnDriveChanged(overlay);
        FindBestFocus(overlay.Frame.HeadContainer.SearchBar);
    end
end

-----------------------------------------------------------
-- Description

signalTable.OnDescriptionGetFocus = function(caller, signal)
    caller:Changed() -- update content from potential external changes
    caller:SetCursorToEnd();
end

-----------------------------------------------------------
-- Wrong Char Warning

signalTable.ShowWarning = function(caller,status,creator)
    local overlay = caller:GetOverlay();
    overlay.Title.WarningButton.ShowAnimation(status);
end

-----------------------------------------------------------
-- Additional Content Button handling (History, Description, ...)

function signalTable.HistoryClicked(caller)
    local overlay = caller:GetOverlay()
    local historyVisible = caller.Target.Visible
    Root().ShowData.ShowSettings.ShowMetaData.ShowShowHistory = historyVisible

    if (historyVisible) then
        overlay.Frame.History.ShowHistoryGrid.CurrentSelectedShowFile = overlay.Frame.ShowFilesViewContainer.ShowFilesView.SelectedFile;
        overlay.Frame.History.ShowHistoryGrid.ReTriggerInit();
    end
end

signalTable.ToggleAdditionalContent = function(caller,signal)
    local o = caller:GetOverlay()
    local description = o.Frame.Description
    local history = o.Frame.History

    if signal == "History" then
        description.visible = false;
        signalTable.HistoryClicked(caller)
    end
    if signal == "Description" then
        history.visible = false;
        Root().ShowData.ShowSettings.ShowMetaData.ShowShowHistory = false
    end
end

signalTable.OpenDescriptionInput = function(caller)
    local object = ShowData().ShowSettings.ShowMetaData
    CmdIndirect("Edit "..object:ToAddr().." property 'Description'")
end

-----------------------------------------------------------
-- CheckLoadAllClicked

signalTable.CheckLoadAllClicked = function(caller)
    local backupmenu = caller:GetOverlay()
    backupmenu.ShowFileSegmentShowData = 1
    backupmenu.ShowFileSegmentLocalSettings = 1
    backupmenu.ShowFileSegmentOutputStations = 1
    backupmenu.ShowFileSegmentDmxProtocols = 1
end

-----------------------------------------------------------
-- CheckLoadDefaultsClicked

signalTable.CheckLoadDefaultsClicked = function(caller)
    local backupmenu = caller:GetOverlay()
    backupmenu.ShowFileSegmentShowData = 1
    backupmenu.ShowFileSegmentLocalSettings = 0
    backupmenu.ShowFileSegmentOutputStations = 0
    backupmenu.ShowFileSegmentDmxProtocols = 0
end

signalTable.UpdateDescription = function(caller, readOnly)
    local overlay = caller:GetOverlay()
    if (readOnly) then
        -- SHOW DESCRIPTION
        overlay.Frame.ButtonArea.Description.Text = "Show\nDescription"
        if (overlay.Mode == Enums.ShowfileSelectorMode.Newshow) then
            overlay.Frame.Description.DescriptionLabel.Text = "Description of the new show file:"            
        else
            overlay.Frame.Description.DescriptionLabel.Text = "Description of the selected show file:"
        end
        
        local showName = signalTable.CutShowEnding(overlay.Frame.ShowFilesViewContainer.ShowFilesView.SelectedFile)
        local newTarget = CmdObj().ShowMetaDataCollect[showName]
        overlay.Frame.Description.Input.InputField.Target = newTarget
        overlay.Frame.Description.Input.InputField.Focus = "Never"
        overlay.Frame.Description.Input.KeyboardBtn.Enabled = false
    else
        -- EDIT DESCRIPTION
        overlay.Frame.ButtonArea.Description.Text = "Edit\nDescription"
        if (overlay.Mode == Enums.ShowfileSelectorMode.Newshow) then
            overlay.Frame.Description.DescriptionLabel.Text = "Description of the new show file:"
        else
            overlay.Frame.Description.DescriptionLabel.Text = "Description of the currently loaded showfile:"
        end
        overlay.Frame.Description.Input.InputField.Target = Root().ShowData.ShowSettings.ShowMetaData
        overlay.Frame.Description.Input.InputField.Focus = "CanHaveFocus"
        overlay.Frame.Description.Input.KeyboardBtn.Enabled = true
    end
end

-----------------------------------------------------------
-- ExecuteOnEnter

signalTable.ExecuteOnEnter = function(caller,dummy,keyCode)
    local overlay = caller:GetOverlay();
    if caller.HasFocus and keyCode == Enums.KeyboardCodes.Enter then
        if overlay.Mode == Enums.ShowfileSelectorMode.Load and not signalTable.GridHasMultiSelection(overlay) then
            signalTable.LoadShow(caller)
        elseif overlay.Mode == Enums.ShowfileSelectorMode.Saveas and not signalTable.GridHasMultiSelection(overlay) then
            signalTable.SaveShowAs(caller)
        elseif overlay.Mode == Enums.ShowfileSelectorMode.Delete then
            signalTable.DeleteShow(caller)
        elseif overlay.Mode == Enums.ShowfileSelectorMode.Newshow then
            signalTable.NewShow(caller)
        end
    end
end

-----------------------------------------------------------
-- UpdateDiskStatus

signalTable.UpdateDiskStatus = function(caller)
    caller.Drive = SelectedDrive()
    caller.WarningTooltip = "Your hard drive is getting full. We recommend you delete old show files and all backup files."
end
